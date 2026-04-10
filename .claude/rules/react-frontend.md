# React Frontend Implementation — Best Practices

Apply these rules when building or modifying a React frontend with TypeScript. These are production-grade conventions — follow them unless the project's own CLAUDE.md or conventions explicitly override.

---

## 1. Project Structure

Group by feature/domain, not by file type. Keep related code close together.

```
src/
├── app/                        # App shell
│   ├── App.tsx                 # Root component, providers, router
│   ├── routes.tsx              # Route configuration
│   └── providers.tsx           # Composed context providers
├── features/                   # Feature modules (primary organization)
│   ├── auth/
│   │   ├── components/         # Feature-specific components
│   │   │   ├── LoginForm.tsx
│   │   │   └── SignupForm.tsx
│   │   ├── hooks/              # Feature-specific hooks
│   │   │   └── useAuth.ts
│   │   ├── api.ts              # API calls for this feature
│   │   ├── types.ts            # Types for this feature
│   │   └── index.ts            # Public API (re-exports)
│   └── items/
│       ├── components/
│       ├── hooks/
│       ├── api.ts
│       ├── types.ts
│       └── index.ts
├── components/                 # Shared/generic UI components
│   ├── ui/                     # Primitives (Button, Input, Modal, Card)
│   └── layout/                 # Layout components (Sidebar, Header, PageShell)
├── hooks/                      # Shared custom hooks
│   ├── useDebounce.ts
│   └── useLocalStorage.ts
├── lib/                        # Shared utilities
│   ├── api-client.ts           # Configured fetch/axios instance
│   ├── query-client.ts         # TanStack Query client config
│   └── utils.ts                # Pure utility functions
├── types/                      # Global/shared types
│   └── api.ts                  # API response types, error shapes
└── styles/                     # Global styles (if not using CSS-in-JS)
    └── globals.css
```

Key rules:
- **`features/`** is the primary organization unit. Each feature is a self-contained module with its own components, hooks, API calls, and types.
- **`components/`** at root level is for truly shared, generic UI primitives — not feature-specific components.
- Every feature folder has an `index.ts` that re-exports its public API. Other features import from `features/auth`, never from `features/auth/components/LoginForm`.
- For small projects (< 3 features), a flat layout is fine. Don't create empty directories preemptively.

---

## 2. Component Patterns

### Functional components with TypeScript

Always use TypeScript interfaces for props. Use explicit return types only when they add clarity.

```tsx
interface UserCardProps {
  user: User;
  onEdit: (id: string) => void;
  variant?: "compact" | "full";
}

function UserCard({ user, onEdit, variant = "full" }: UserCardProps) {
  return (
    <div className={styles[variant]}>
      <h3>{user.name}</h3>
      {variant === "full" && <p>{user.bio}</p>}
      <button onClick={() => onEdit(user.id)}>Edit</button>
    </div>
  );
}
```

### Component design rules

- **Named exports** for components (not default exports) — makes refactoring and searching easier.
- **One component per file** for anything non-trivial. Small helper components can live in the same file.
- **Props interfaces** named `ComponentNameProps` — e.g., `UserCardProps`.
- **Destructure props** in the function signature, not in the body.
- **Use `children` via `React.ReactNode`** for composition, not render props (unless conditional rendering is needed).
- **Avoid prop drilling beyond 2 levels** — use context or composition instead.

### Composition over configuration

Prefer composing small components over building one component with many props:

```tsx
// Prefer this (composition)
<Card>
  <Card.Header>
    <Card.Title>Settings</Card.Title>
  </Card.Header>
  <Card.Body>...</Card.Body>
</Card>

// Over this (configuration)
<Card
  title="Settings"
  headerAction={<Button />}
  body={...}
  footer={...}
/>
```

### Compound components pattern

For tightly related UI that shares state:

```tsx
const TabsContext = createContext<TabsContextValue | null>(null);

function Tabs({ children, defaultValue }: TabsProps) {
  const [active, setActive] = useState(defaultValue);
  return (
    <TabsContext value={{ active, setActive }}>
      <div role="tablist">{children}</div>
    </TabsContext>
  );
}

function TabPanel({ value, children }: TabPanelProps) {
  const ctx = use(TabsContext);
  if (!ctx) throw new Error("TabPanel must be used within Tabs");
  if (ctx.active !== value) return null;
  return <div role="tabpanel">{children}</div>;
}

Tabs.Panel = TabPanel;
```

---

## 3. Hooks Best Practices

### useState

- Use for **local UI state** only (form inputs, toggles, modals, selected items).
- Use **functional updates** when new state depends on previous state: `setCount(prev => prev + 1)`.
- For complex state with multiple related fields, use `useReducer` instead.

### useEffect

- **Every effect should have a single, clear purpose.** If your effect does two things, split it into two effects.
- **Always specify dependencies correctly.** Never suppress the linter with `// eslint-disable-next-line`.
- **Clean up side effects** — return a cleanup function for subscriptions, timers, event listeners.
- **Avoid using effects for:**
  - Transforming data for rendering — use `useMemo` or compute during render
  - Responding to user events — use event handlers
  - Syncing state — derive it instead

```tsx
// BAD: effect to transform data
useEffect(() => {
  setFilteredItems(items.filter(i => i.active));
}, [items]);

// GOOD: compute during render
const filteredItems = useMemo(
  () => items.filter(i => i.active),
  [items]
);
```

### useCallback and useMemo

- **`useCallback`** — wrap callbacks passed to memoized child components or used in effect dependencies.
- **`useMemo`** — wrap expensive computations. Don't memoize everything — only when profiling shows it matters.
- **Custom hooks should wrap returned functions in `useCallback`** — gives consumers stable references.

```tsx
function useRouter() {
  const { dispatch } = useContext(RouterContext);

  const navigate = useCallback((url: string) => {
    dispatch({ type: "navigate", url });
  }, [dispatch]);

  return { navigate };
}
```

### useReducer

Use when state has complex transitions or multiple related fields:

```tsx
type State = { items: Item[]; status: "idle" | "loading" | "error"; error: string | null };
type Action =
  | { type: "fetch_start" }
  | { type: "fetch_success"; items: Item[] }
  | { type: "fetch_error"; error: string };

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case "fetch_start":
      return { ...state, status: "loading", error: null };
    case "fetch_success":
      return { ...state, status: "idle", items: action.items };
    case "fetch_error":
      return { ...state, status: "error", error: action.error };
  }
}
```

### Custom hooks

- **Name them `use*`** — always prefix with `use`.
- **Extract shared stateful logic** — if two components share the same useState + useEffect pattern, extract it.
- **Return objects (not arrays)** when returning more than 2 values — easier to destructure selectively.
- **Keep hooks focused** — one hook, one responsibility.

```tsx
function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);

  return debouncedValue;
}
```

---

## 4. Data Fetching with TanStack Query

Use TanStack Query (React Query) for all server state. Don't manage server data with useState + useEffect.

### Setup

```tsx
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60,       // 1 minute
      gcTime: 1000 * 60 * 5,      // 5 minutes (garbage collection)
      retry: 1,
      refetchOnWindowFocus: false, // opt-in per query if needed
    },
  },
});

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      {/* app */}
    </QueryClientProvider>
  );
}
```

### Query key conventions

Use a factory pattern for consistent, hierarchical keys:

```tsx
// features/items/api.ts
export const itemKeys = {
  all:    ["items"] as const,
  lists:  () => [...itemKeys.all, "list"] as const,
  list:   (filters: ItemFilters) => [...itemKeys.lists(), filters] as const,
  details:() => [...itemKeys.all, "detail"] as const,
  detail: (id: string) => [...itemKeys.details(), id] as const,
};
```

This enables granular invalidation:
```tsx
// Invalidate all item queries
queryClient.invalidateQueries({ queryKey: itemKeys.all });

// Invalidate only lists (not details)
queryClient.invalidateQueries({ queryKey: itemKeys.lists() });
```

### Queries

```tsx
function useItems(filters: ItemFilters) {
  return useQuery({
    queryKey: itemKeys.list(filters),
    queryFn: () => api.getItems(filters),
  });
}

function useItem(id: string) {
  return useQuery({
    queryKey: itemKeys.detail(id),
    queryFn: () => api.getItem(id),
    enabled: !!id,  // don't fetch if id is empty
  });
}
```

### Mutations

```tsx
function useCreateItem() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateItemInput) => api.createItem(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: itemKeys.lists() });
    },
  });
}
```

### Optimistic updates

Use `onMutate` for instant UI feedback, `onError` for rollback:

```tsx
function useUpdateItem() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateItemInput }) =>
      api.updateItem(id, data),
    onMutate: async ({ id, data }) => {
      await queryClient.cancelQueries({ queryKey: itemKeys.detail(id) });
      const previous = queryClient.getQueryData(itemKeys.detail(id));
      queryClient.setQueryData(itemKeys.detail(id), (old: Item) => ({
        ...old,
        ...data,
      }));
      return { previous };
    },
    onError: (_err, { id }, context) => {
      if (context?.previous) {
        queryClient.setQueryData(itemKeys.detail(id), context.previous);
      }
    },
    onSettled: (_data, _err, { id }) => {
      queryClient.invalidateQueries({ queryKey: itemKeys.detail(id) });
    },
  });
}
```

### Key rules

- **Query keys must include all variables** the query depends on (filters, IDs, search terms).
- **Use `enabled`** for dependent queries — don't fetch until prerequisite data is available.
- **Invalidate on mutations** — use `onSuccess` or `onSettled` to refetch stale data.
- **Set appropriate `staleTime`** — data that rarely changes can be stale longer. Default 1 minute is a good starting point.
- **Colocate query hooks with their feature** — `features/items/hooks/useItems.ts`.

---

## 5. API Client Layer

Centralize HTTP calls with a typed API client. Keep it separate from UI concerns.

```tsx
// lib/api-client.ts
const API_BASE = import.meta.env.VITE_API_URL ?? "http://localhost:8000";

class ApiError extends Error {
  constructor(
    public status: number,
    public detail: string,
    public body?: unknown,
  ) {
    super(detail);
  }
}

async function request<T>(
  path: string,
  options: RequestInit = {},
): Promise<T> {
  const token = localStorage.getItem("access_token");

  const res = await fetch(`${API_BASE}${path}`, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...(token && { Authorization: `Bearer ${token}` }),
      ...options.headers,
    },
  });

  if (!res.ok) {
    const body = await res.json().catch(() => null);
    throw new ApiError(res.status, body?.detail ?? res.statusText, body);
  }

  if (res.status === 204) return undefined as T;
  return res.json();
}

export const api = {
  get: <T>(path: string) => request<T>(path),
  post: <T>(path: string, data: unknown) =>
    request<T>(path, { method: "POST", body: JSON.stringify(data) }),
  patch: <T>(path: string, data: unknown) =>
    request<T>(path, { method: "PATCH", body: JSON.stringify(data) }),
  put: <T>(path: string, data: unknown) =>
    request<T>(path, { method: "PUT", body: JSON.stringify(data) }),
  delete: <T>(path: string) =>
    request<T>(path, { method: "DELETE" }),
};
```

Then in feature API files:

```tsx
// features/items/api.ts
import { api } from "@/lib/api-client";
import type { Item, CreateItemInput, UpdateItemInput } from "./types";

export const itemsApi = {
  getAll: (params?: URLSearchParams) =>
    api.get<Item[]>(`/api/v1/items?${params ?? ""}`),
  getById: (id: string) =>
    api.get<Item>(`/api/v1/items/${id}`),
  create: (data: CreateItemInput) =>
    api.post<Item>("/api/v1/items", data),
  update: (id: string, data: UpdateItemInput) =>
    api.patch<Item>(`/api/v1/items/${id}`, data),
  delete: (id: string) =>
    api.delete<void>(`/api/v1/items/${id}`),
};
```

Key rules:
- **One API client instance** configured with base URL, auth headers, and error handling.
- **Feature API files** use the shared client — they don't configure HTTP themselves.
- **Type every response** — the API client is the boundary where types are applied.
- **`ApiError` class** — makes it easy to check error types in mutation/query error handlers.
- **Environment variables** for API base URL — never hardcode URLs.

---

## 6. Routing

### React Router configuration

```tsx
// app/routes.tsx
import { createBrowserRouter, Navigate, Outlet } from "react-router-dom";
import { AppLayout } from "@/components/layout/AppLayout";
import { AuthLayout } from "@/components/layout/AuthLayout";
import { ProtectedRoute } from "@/features/auth/components/ProtectedRoute";

export const router = createBrowserRouter([
  {
    element: <AuthLayout />,
    children: [
      { path: "/login", lazy: () => import("@/features/auth/components/LoginPage") },
      { path: "/signup", lazy: () => import("@/features/auth/components/SignupPage") },
    ],
  },
  {
    element: (
      <ProtectedRoute>
        <AppLayout />
      </ProtectedRoute>
    ),
    children: [
      { index: true, element: <Navigate to="/dashboard" replace /> },
      { path: "/dashboard", lazy: () => import("@/features/dashboard/DashboardPage") },
      {
        path: "/items",
        children: [
          { index: true, lazy: () => import("@/features/items/components/ItemListPage") },
          { path: ":id", lazy: () => import("@/features/items/components/ItemDetailPage") },
        ],
      },
    ],
  },
]);
```

### Protected route pattern

```tsx
function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { user, isLoading } = useAuth();

  if (isLoading) return <LoadingSpinner />;
  if (!user) return <Navigate to="/login" replace />;

  return <>{children}</>;
}
```

### Key rules

- **Use `lazy` for route-level code splitting** — each page loads on demand.
- **Layout routes** for shared UI (sidebar, header) — use `<Outlet />` for nested content.
- **Protected routes** wrap authenticated sections — redirect to login if unauthenticated.
- **Use `useParams` with type assertions** — React Router params are always `string | undefined`.

---

## 7. Forms

### Controlled forms with validation

For simple forms, use controlled components. For complex forms, consider a form library (React Hook Form, Formik).

```tsx
interface LoginFormData {
  email: string;
  password: string;
}

function LoginForm({ onSubmit }: { onSubmit: (data: LoginFormData) => void }) {
  const [form, setForm] = useState<LoginFormData>({ email: "", password: "" });
  const [errors, setErrors] = useState<Partial<Record<keyof LoginFormData, string>>>({});

  function validate(data: LoginFormData) {
    const errs: typeof errors = {};
    if (!data.email) errs.email = "Email is required";
    if (!data.password) errs.password = "Password is required";
    return errs;
  }

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    const errs = validate(form);
    if (Object.keys(errs).length > 0) {
      setErrors(errs);
      return;
    }
    onSubmit(form);
  }

  return (
    <form onSubmit={handleSubmit}>
      <div>
        <label htmlFor="email">Email</label>
        <input
          id="email"
          type="email"
          value={form.email}
          onChange={(e) => setForm(prev => ({ ...prev, email: e.target.value }))}
        />
        {errors.email && <span role="alert">{errors.email}</span>}
      </div>
      {/* password field similarly */}
      <button type="submit">Log in</button>
    </form>
  );
}
```

### Key rules

- **Always use `<label>` with `htmlFor`** — accessibility requirement.
- **Show validation errors inline** next to the field, with `role="alert"`.
- **Disable submit button** during async submission to prevent double-submit.
- **Use `useFormStatus`** in child components to track parent form submission state.
- **Derive form validity** — don't sync validation state with effects.

---

## 8. State Management

### Decision framework

| State type | Solution | Example |
|:--|:--|:--|
| **Local UI state** | `useState` / `useReducer` | Modal open, form inputs, selected tab |
| **Server state** | TanStack Query | API data, cached responses |
| **Shared UI state** | Context + `useReducer` | Theme, sidebar collapsed, toast notifications |
| **Complex client state** | Zustand or Jotai | Shopping cart, multi-step wizard, drag-and-drop |
| **URL state** | React Router (`useSearchParams`) | Filters, pagination, sort order |

### Context usage rules

- **Context is for infrequently-changing, widely-needed state** — theme, auth user, locale.
- **Memoize context values** to prevent unnecessary re-renders:

```tsx
function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);

  const value = useMemo(
    () => ({ user, setUser }),
    [user],
  );

  return <AuthContext value={value}>{children}</AuthContext>;
}
```

- **Split contexts by update frequency** — don't put rarely-changed auth data in the same context as frequently-changing UI state.
- **Never use context as a global store** for everything — that's what Zustand/Jotai are for.

### URL state for filters/pagination

```tsx
function ItemListPage() {
  const [searchParams, setSearchParams] = useSearchParams();
  const page = Number(searchParams.get("page") ?? "1");
  const sort = searchParams.get("sort") ?? "created_at";

  const { data } = useItems({ page, sort });

  function setPage(newPage: number) {
    setSearchParams(prev => {
      prev.set("page", String(newPage));
      return prev;
    });
  }

  // ...
}
```

Key rule: **If it should survive a page refresh or be shareable via URL, it belongs in URL state, not component state.**

---

## 9. Error Handling

### Error boundaries

Wrap route-level and feature-level components with error boundaries:

```tsx
import { ErrorBoundary } from "react-error-boundary";

function ErrorFallback({ error, resetErrorBoundary }: FallbackProps) {
  return (
    <div role="alert">
      <h2>Something went wrong</h2>
      <p>{error.message}</p>
      <button onClick={resetErrorBoundary}>Try again</button>
    </div>
  );
}

// In route config or layout
<ErrorBoundary FallbackComponent={ErrorFallback}>
  <Outlet />
</ErrorBoundary>
```

### Error handling layers

| Layer | How to handle | Example |
|:--|:--|:--|
| **API client** | Throw typed `ApiError` | 401 -> redirect to login, 500 -> generic error |
| **TanStack Query** | `onError` callback or `error` state | Show toast, inline error message |
| **Component** | Error boundary | Catch rendering errors, show fallback UI |
| **Form** | Inline validation errors | Field-level error messages |

### Key rules

- **Never silently swallow errors** — always show feedback to the user.
- **Use error boundaries at route boundaries** — a broken page shouldn't crash the whole app.
- **Handle 401 globally** — intercept in the API client, redirect to login, clear auth state.
- **Show user-friendly messages** — don't expose raw error details in production.
- **Use Suspense with error boundaries** for data loading states:

```tsx
<ErrorBoundary FallbackComponent={ErrorFallback}>
  <Suspense fallback={<Skeleton />}>
    <ItemList />
  </Suspense>
</ErrorBoundary>
```

---

## 10. Performance

### Code splitting

- **Route-level splitting** with `lazy()` — each page is a separate chunk.
- **Heavy component splitting** with `React.lazy` + `Suspense` for large components (charts, editors, maps).

```tsx
const Chart = lazy(() => import("./Chart"));

function Dashboard() {
  return (
    <Suspense fallback={<ChartSkeleton />}>
      <Chart data={data} />
    </Suspense>
  );
}
```

### Memoization

- **`React.memo`** — wrap components that re-render frequently with the same props (list items, table rows).
- **`useMemo`** — expensive computations (filtering/sorting large arrays, complex derived data).
- **`useCallback`** — callbacks passed to memoized children or used in dependency arrays.
- **Don't memoize by default** — profile first, optimize second.

### List rendering

- **Always use stable, unique `key` props** — never use array index as key for dynamic lists.
- **Virtualize long lists** with `@tanstack/react-virtual` or `react-window` — don't render 1000 DOM nodes.

### General rules

- **Avoid creating objects/arrays in JSX props** — they cause re-renders because they're new references every render.
- **Avoid inline function definitions in JSX** for memoized children — extract to `useCallback`.
- **Debounce search inputs** — don't fire a query on every keystroke.
- **Use `loading` attribute on images** — `<img loading="lazy" />` for below-fold images.

---

## 11. TypeScript Patterns

### Props typing

```tsx
// Interface for component props
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "secondary" | "danger";
  size?: "sm" | "md" | "lg";
  isLoading?: boolean;
}

// Generic component
interface ListProps<T> {
  items: T[];
  renderItem: (item: T) => React.ReactNode;
  keyExtractor: (item: T) => string;
}

function List<T>({ items, renderItem, keyExtractor }: ListProps<T>) {
  return (
    <ul>
      {items.map((item) => (
        <li key={keyExtractor(item)}>{renderItem(item)}</li>
      ))}
    </ul>
  );
}
```

### Event handlers

```tsx
function handleChange(e: React.ChangeEvent<HTMLInputElement>) { ... }
function handleSubmit(e: React.FormEvent<HTMLFormElement>) { ... }
function handleClick(e: React.MouseEvent<HTMLButtonElement>) { ... }
```

### Key rules

- **Use `interface` for props**, `type` for unions and utility types.
- **Extend native HTML attributes** when wrapping native elements: `extends React.InputHTMLAttributes<HTMLInputElement>`.
- **Use `React.ReactNode`** for children props, not `React.ReactElement` or `JSX.Element`.
- **Avoid `any`** — use `unknown` and narrow with type guards.
- **Use `as const`** for literal tuples (query keys, action types).
- **Use discriminated unions** for state that has mutually exclusive shapes.

```tsx
type AsyncState<T> =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: T }
  | { status: "error"; error: Error };
```

---

## 12. Testing

### Testing stack

| Tool | Purpose |
|:--|:--|
| Vitest | Test runner (fast, Vite-native) |
| React Testing Library | Component testing (user-centric) |
| MSW (Mock Service Worker) | API mocking at the network level |
| Playwright | E2E testing |

### Component testing philosophy

**Test behavior, not implementation.** Query by what the user sees, not by component internals.

```tsx
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

test("submits login form with email and password", async () => {
  const onSubmit = vi.fn();
  render(<LoginForm onSubmit={onSubmit} />);

  await userEvent.type(screen.getByLabelText(/email/i), "user@test.com");
  await userEvent.type(screen.getByLabelText(/password/i), "pass123");
  await userEvent.click(screen.getByRole("button", { name: /log in/i }));

  expect(onSubmit).toHaveBeenCalledWith({
    email: "user@test.com",
    password: "pass123",
  });
});
```

### Query priority (React Testing Library)

1. `getByRole` — accessible roles (button, textbox, heading)
2. `getByLabelText` — form inputs
3. `getByPlaceholderText` — when no label exists
4. `getByText` — non-interactive elements
5. `getByTestId` — last resort only

### Testing with TanStack Query

Wrap components in a fresh `QueryClientProvider` per test:

```tsx
function renderWithProviders(ui: React.ReactElement) {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
    },
  });

  return render(
    <QueryClientProvider client={queryClient}>
      {ui}
    </QueryClientProvider>,
  );
}
```

### API mocking with MSW

```tsx
import { http, HttpResponse } from "msw";
import { setupServer } from "msw/node";

const server = setupServer(
  http.get("/api/v1/items", () => {
    return HttpResponse.json([
      { id: "1", title: "Test Item" },
    ]);
  }),
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

### Key rules

- **Use `userEvent` over `fireEvent`** — it simulates real user interactions more accurately.
- **Use `waitFor` for async assertions** — don't use arbitrary timeouts.
- **Mock at the network level (MSW)**, not at the module level — tests stay closer to production behavior.
- **Test user-visible behavior** — "when I click X, I should see Y", not "when I click X, setState is called".
- **Don't test implementation details** — don't assert on state values, internal methods, or component instances.

---

## 13. Security

- **Never store tokens in `localStorage` for high-security apps** — use `httpOnly` cookies set by the backend. `localStorage` is acceptable for low-risk apps.
- **Sanitize user-generated content** — React escapes JSX by default, but `dangerouslySetInnerHTML` bypasses this. Never use it with untrusted content.
- **Validate on the backend** — frontend validation is for UX, not security.
- **Environment variables** for API URLs and public keys — never commit secrets to frontend code.
- **Use `Content-Security-Policy` headers** — configured by the backend/CDN, enforced by the browser.
- **CORS is a server concern** — the frontend doesn't configure CORS, but it needs to know the API origin.

---

## 14. Styling Approach

This rule is intentionally flexible on styling. Use whatever the project uses. Common patterns:

| Approach | When to use |
|:--|:--|
| **Tailwind CSS** | Most projects — utility-first, fast iteration, consistent design |
| **CSS Modules** | When you need scoped CSS without a runtime |
| **styled-components / Emotion** | When you need dynamic styles based on props |
| **Vanilla CSS** | Small projects, simple needs |

Regardless of approach:
- **Use design tokens** (colors, spacing, typography) — don't hardcode values.
- **Mobile-first responsive design** — start with small screens, add breakpoints up.
- **Use semantic HTML** — `<button>` not `<div onClick>`, `<nav>` not `<div class="nav">`.
- **Accessible color contrast** — minimum 4.5:1 for normal text, 3:1 for large text.

---

## 15. Full-Stack Integration with FastAPI

When this frontend connects to a FastAPI backend (see `fastapi-backend.md` rule):

### Type alignment

- Backend Pydantic response schemas should match frontend TypeScript types.
- Use a single source of truth — either generate TypeScript types from OpenAPI spec, or manually keep them in sync.

```tsx
// Frontend type should match backend ItemResponse schema
interface Item {
  id: number;
  title: string;
  description: string | null;
  created_at: string;    // ISO 8601 from backend
  updated_at: string;
}
```

### API versioning

- Frontend API client should target a specific version: `/api/v1/...`.
- Update frontend when backend introduces v2 — don't mix versions.

### Authentication flow

```
1. User submits credentials -> POST /api/v1/auth/login
2. Backend returns JWT access token
3. Frontend stores token (localStorage or httpOnly cookie)
4. Frontend sends Authorization: Bearer <token> with every request
5. On 401 response -> clear token, redirect to /login
```

### CORS

The FastAPI backend must allow the frontend's origin:
```python
# Backend
ALLOWED_ORIGINS=["http://localhost:5173"]  # Vite dev server
```

---

## Quick Reference: Dependencies to Use

| Package | Purpose |
|:--|:--|
| `react` + `react-dom` | Core library |
| `typescript` | Type safety |
| `vite` | Build tool and dev server |
| `@tanstack/react-query` | Server state management |
| `react-router-dom` | Client-side routing |
| `react-error-boundary` | Declarative error handling |
| `zustand` or `jotai` | Complex client state (if needed) |
| `tailwindcss` | Utility-first CSS (if chosen) |
| `vitest` | Test runner |
| `@testing-library/react` | Component testing |
| `@testing-library/user-event` | User interaction simulation |
| `msw` | API mocking |
| `playwright` | E2E testing |
| `@tanstack/react-virtual` | List virtualization (if needed) |
