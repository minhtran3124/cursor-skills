---
name: qa
description: Design and implement a test suite by analyzing risk areas, writing tests at every level of the pyramid, and producing a quality report. Use when adding tests, improving coverage, or validating a feature end-to-end.
---

# Test Strategy

Design and implement a thorough test suite — analyze the codebase for risk, write tests at every layer, and produce a quality report at `.qa/report.md`.

## Step 1: Analyze the Codebase

Before writing any tests, understand what exists:

- Read the source code being tested — understand the happy path and all branches
- Read existing tests — understand what's already covered and what patterns are used
- Read `progress.md` and `.review/review.md` if they exist — understand what changed recently
- Run existing tests to establish a baseline (note any that are already failing)

Identify:
- **High-risk areas** — code that handles money, auth, data mutations, external calls
- **Complex logic** — functions with many branches, state machines, recursive operations
- **Integration points** — API boundaries, database queries, third-party service calls
- **Uncovered paths** — branches, error handlers, and edge cases with no tests

## Step 2: Design the Test Plan

Propose a test plan organized by the test pyramid:

```
Test plan:

Unit tests (fast, isolated):
[1] OrderService.calculate_total — pricing logic with discounts, taxes, edge cases
[2] validate_email — format validation, edge cases (unicode, long inputs)
[3] Permission checks — role-based access for each operation

Integration tests (real dependencies):
[4] POST /api/orders — full request→database→response cycle
[5] Order + Inventory interaction — stock decremented on order creation

E2E tests (critical paths only):
[6] Checkout flow — browse → add to cart → checkout → confirmation

Priority: [1] and [4] are highest risk. [6] only if E2E framework exists.
```

Wait for confirmation before writing tests.

### What to Test (and What Not To)

**Always test:**
- Business logic with meaningful inputs and expected outputs
- Edge cases: empty inputs, boundary values, null/undefined, max lengths
- Error paths: what happens when things fail (invalid input, missing data, network errors)
- Security-sensitive code: auth, permissions, input validation, data sanitization

**Don't test:**
- Framework internals (don't test that Express routes or Django views work)
- Trivial getters/setters with no logic
- Third-party libraries (they have their own tests)
- Implementation details that change when refactoring (test behavior, not structure)

## Step 3: Write Unit Tests

Unit tests are fast, isolated, and focused on a single function or method:

**3a. Structure each test clearly:**

```
# Arrange — set up input data and dependencies
# Act — call the function under test
# Assert — verify the output or side effects
```

**3b. Name tests descriptively:**

```
Good:  test_calculate_total_applies_percentage_discount_before_tax
Good:  test_create_order_raises_error_when_inventory_insufficient
Bad:   test_calculate_total_1
Bad:   test_order_works
```

**3c. One assertion per behavior** — A test should verify one behavior. Multiple assertions are fine if they all verify the same behavior (e.g., checking both the return value and a side effect of the same call).

**3d. Use realistic data** — Don't test with empty strings and zeros if the function normally receives names and prices. Use data that resembles production.

**3e. Test boundaries:**

```
For a function that accepts quantity (1-100):
- Test: 1 (minimum valid)
- Test: 100 (maximum valid)
- Test: 0 (below minimum)
- Test: 101 (above maximum)
- Test: -1 (negative)
- Test: 50 (typical valid value)
```

### Mocking Rules

- Mock external services (HTTP calls, email, payment processors) — always
- Mock the database — only in unit tests, never in integration tests
- Mock the clock — when testing time-dependent logic
- Don't mock the thing you're testing
- Don't mock everything — if a unit test mocks 5 things, it's testing mocks not code
- Prefer fakes (in-memory implementations) over mocks when the interface is simple

## Step 4: Write Integration Tests

Integration tests verify that components work together with real dependencies:

**4a. API endpoint tests** — Send real HTTP requests, hit the real database (test database), verify the full response:

```python
def test_create_order_returns_201_with_order_data():
    response = client.post("/api/orders", json={
        "items": [{"product_id": 1, "quantity": 2}]
    })
    assert response.status_code == 201
    data = response.json()["data"]
    assert data["id"] is not None
    assert len(data["items"]) == 1
```

**4b. Database tests** — Verify that queries return correct data, transactions work, constraints are enforced:

- Test unique constraints (insert duplicate, expect error)
- Test cascade deletes (delete parent, verify children gone)
- Test concurrent operations if relevant (two users editing same record)

**4c. Service interaction tests** — Verify that services compose correctly:

- Service A calls Service B, verify the combined result
- Test error propagation — when Service B fails, Service A handles it correctly

### Integration Test Rules

- Each test starts with a clean state (truncate tables, reset fixtures)
- Tests must not depend on execution order
- Use a test database, never production
- Keep these tests focused — test the integration, not the business logic (that's what unit tests are for)

## Step 5: Write End-to-End Tests

E2E tests verify critical user journeys. Only write these if the project has an E2E framework set up:

**5a. Identify critical paths** — The 3-5 most important user flows that, if broken, would mean the product is unusable.

**5b. Test the happy path and one failure path per flow:**

```
Critical path: User checkout
- Happy: browse → add to cart → enter payment → confirm → see order
- Failure: browse → add to cart → payment declined → see error → retry
```

**5c. Keep E2E tests stable:**
- Use data attributes (`data-testid`) for selectors, not CSS classes
- Wait for elements explicitly (no arbitrary sleeps)
- Reset test data before each run

## Step 6: Generate Quality Report

After writing tests, create `.qa/` directory if needed and generate `.qa/report.md`:

```markdown
# Quality Report

## Summary
[1-3 sentences: what was tested, overall assessment, key risks]

## Coverage

| Area | Unit | Integration | E2E | Risk |
|------|------|-------------|-----|------|
| Order service | 12 tests | 4 tests | 1 flow | Low |
| Auth middleware | 8 tests | 2 tests | — | Low |
| Payment processing | 3 tests | 1 test | — | Medium |

## Tests Written

### Unit Tests
- `tests/unit/test_order_service.py` — 12 tests covering pricing, discounts, inventory checks
- `tests/unit/test_auth.py` — 8 tests covering token validation, role checks, expiry

### Integration Tests
- `tests/integration/test_orders_api.py` — 4 tests covering CRUD operations
- `tests/integration/test_auth_flow.py` — 2 tests covering login and token refresh

## Findings

### Bugs Found
1. **[BUG]** `order_service.py:45` — discount calculation uses integer division,
   truncating cents on orders with odd quantities. Reported to builder/backend.

### Risk Areas (untested)
1. **[RISK]** Concurrent order creation — no locking on inventory decrement.
   Could oversell under load. Recommend adding a database-level lock.

### Recommendations
1. Add load testing for checkout endpoint before launch
2. Payment webhook handler has no idempotency check — duplicate webhooks will create duplicate records
```

## Bug Reporting Format

When tests reveal bugs, report them clearly:

```
**[BUG]** file_path:line_number
What: [one sentence describing the incorrect behavior]
Expected: [what should happen]
Actual: [what does happen]
Reproduce: [test name or steps]
Severity: Critical / High / Medium / Low
```

Message the responsible agent (builder, frontend, or backend) with the bug report.

## Test Quality Principles

- Tests document behavior — a new developer should understand what the code does by reading the tests
- Tests run fast — unit tests in seconds, integration tests in under a minute
- Tests are deterministic — no flaky tests. If a test fails intermittently, fix it or delete it
- Tests are independent — no shared mutable state between tests
- Tests fail for the right reason — a test should fail because the behavior it checks is broken, not because an unrelated change happened
