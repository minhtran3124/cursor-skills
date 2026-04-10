---
name: backend
description: Build backend services by designing the data layer, implementing business logic, exposing API endpoints, and hardening with auth, validation, and error handling. Use when implementing APIs, services, or data pipelines.
---

# Backend Service Development

Build backend features methodically — design the data layer first, implement business logic, expose it through API endpoints, then harden with cross-cutting concerns.

## Step 1: Understand the Service Requirements

Before writing code, read everything available:

- API spec, plan, or description of what to build
- Existing models, schemas, and database structure
- Existing route patterns and middleware stack
- Frontend needs — what data shape the UI expects (check with frontend)

Identify:
- What data entities are involved and their relationships
- What operations are needed (CRUD, workflows, aggregations)
- What external services are called (databases, caches, third-party APIs)
- What auth/permissions model applies

## Step 2: Design the Data Layer

Start with the foundation — data models and storage:

**2a. Define models** — Create or modify data models with all fields, types, relationships, and constraints. Follow the project's ORM conventions (SQLAlchemy, Prisma, Django ORM, etc.).

**2b. Plan migrations** — If the project uses migrations, create them. For schema changes:
- Adding columns: always set a default or make nullable for backward compatibility
- Removing columns: deprecate first if the column is still read anywhere
- Adding tables: include indexes for fields that will be queried/filtered
- Renaming: use the ORM's rename operation, not drop + create

**2c. Seed data** — If the feature needs reference data (categories, roles, config), add it to the project's seed mechanism.

### Data Layer Rules

- Every model has a primary key, created_at, and updated_at
- Use the project's ID strategy (auto-increment, UUID, ULID) — don't mix
- Foreign keys have explicit ON DELETE behavior (CASCADE, SET NULL, RESTRICT)
- Index columns that appear in WHERE clauses and JOIN conditions
- N+1 queries: use eager loading / joins for related data that's always needed

## Step 3: Implement Business Logic

Build the core logic in service functions or classes — not in route handlers:

**3a. Service layer** — Pure business logic. Receives validated data, returns results or raises domain errors. No HTTP concepts (no request objects, no status codes).

```
# Good: service function with clear input/output
def create_order(user_id: int, items: list[OrderItem]) -> Order:
    ...

# Bad: HTTP concerns leaked into business logic
def create_order(request: Request) -> JSONResponse:
    ...
```

**3b. Domain validation** — Validate business rules in the service layer. Distinguish between:
- **Input validation** (handled at the API boundary): type, format, required fields
- **Business validation** (handled in services): "user can't order more than inventory allows"

**3c. Error handling** — Define domain-specific exceptions. Map them to HTTP status codes in the route layer, not in the service.

```
Service layer raises:         Route layer maps to:
─────────────────────         ────────────────────
NotFoundError            →    404
ValidationError          →    422
PermissionDeniedError    →    403
ConflictError            →    409
```

## Step 4: Build API Endpoints

Expose business logic through well-structured endpoints:

**4a. Route structure** — Follow the project's existing patterns. If no convention exists, use resource-based REST:

```
GET    /api/v1/orders          — list (with filtering, pagination)
POST   /api/v1/orders          — create
GET    /api/v1/orders/{id}     — read
PUT    /api/v1/orders/{id}     — full update
PATCH  /api/v1/orders/{id}     — partial update
DELETE /api/v1/orders/{id}     — delete
```

**4b. Request validation** — Validate and parse all input at the boundary using the framework's validation (Pydantic, Zod, Joi, marshmallow). Reject bad input before it reaches the service layer.

**4c. Response format** — Consistent response structure across all endpoints:

```json
{
  "data": { ... },
  "meta": { "page": 1, "total": 42 }
}
```

For errors:
```json
{
  "error": { "code": "VALIDATION_ERROR", "message": "...", "details": [...] }
}
```

**4d. Pagination** — For list endpoints, always paginate. Use cursor-based pagination for large datasets, offset-based for smaller ones. Include total count if feasible.

**4e. Filtering and sorting** — Accept query parameters for common filters. Whitelist allowed filter/sort fields — never pass user input directly to a query builder.

### API Design Rules

- Use plural nouns for resource names (`/orders`, not `/order`)
- Return the created/updated resource in POST/PUT/PATCH responses
- Use 201 for creation, 204 for deletion, 200 for everything else that succeeds
- Include Location header for 201 responses
- Version the API if the project uses versioning

## Step 5: Add Cross-Cutting Concerns

**Authentication** — Use the project's existing auth mechanism. If building new:
- Never store passwords in plaintext — use bcrypt or argon2
- Tokens: short-lived access tokens + refresh tokens
- API keys: hash before storing, prefix for identification

**Authorization** — Check permissions at the route level before calling the service:
- Role-based: check user role against required role
- Resource-based: check ownership / team membership
- Never rely solely on client-side permissions checks

**Logging** — Log at service boundaries:
- INFO: successful operations with entity IDs (not PII)
- WARNING: unusual but handled situations (rate limit approached, fallback used)
- ERROR: unhandled exceptions, external service failures
- Never log: passwords, tokens, full credit card numbers, PII

**Rate limiting** — Apply to public endpoints. Use the project's rate limiting middleware or add one at the route level.

**Caching** — Cache only when profiling shows a need:
- Cache reads that are expensive and don't change often
- Invalidate on writes — stale data is worse than slow data
- Use cache headers (ETag, Cache-Control) for HTTP caching

## Step 6: Verify and Harden

Before marking the feature complete, check:

### Security Checklist
- [ ] SQL injection: parameterized queries only (never string concatenation)
- [ ] Input validation: all user input validated at the boundary
- [ ] Auth: endpoints require authentication where expected
- [ ] Secrets: no hardcoded credentials, API keys, or tokens in source
- [ ] CORS: configured for known origins only (not wildcard in production)
- [ ] Mass assignment: only accept explicitly allowed fields for create/update

### Reliability Checklist
- [ ] External calls have timeouts and error handling
- [ ] Database transactions are used for multi-step operations
- [ ] Concurrent requests don't cause race conditions on shared state
- [ ] Large result sets are paginated

## Handling Frontend Needs

When frontend messages about a needed endpoint or data shape:

1. Confirm the request/response contract
2. Build the endpoint to match the agreed shape
3. Message **frontend** when the endpoint is live
4. If the shape needs to change for backend reasons, message frontend before changing

Never break an agreed API contract without communicating the change.

## Log to progress.md

After completing each service or group of related endpoints, append:

```markdown
---

## Backend: [Service/Feature Name]

**Status:** Complete
**Files changed:** `app/models/order.py` (created), `app/routes/orders.py` (created), `app/services/order_service.py` (created)

### What changed
[2-4 sentences: what was built, what endpoints are available, how it connects to the data layer]
```
