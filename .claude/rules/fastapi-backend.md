# FastAPI Backend Implementation — Best Practices

Apply these rules when building or modifying a Python backend that uses FastAPI, Pydantic, and SQLAlchemy (or similar async ORM). These are production-grade conventions — follow them unless the project's own CLAUDE.md or conventions explicitly override.

---

## 1. Project Structure

Use a modular layout. Group by domain/feature, not by technical layer.

```
project/
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI app factory + lifespan
│   ├── config.py             # pydantic-settings BaseSettings
│   ├── dependencies.py       # shared Depends() callables
│   ├── exceptions.py         # custom exception classes + handlers
│   ├── database.py           # engine, async session factory
│   ├── models/               # SQLAlchemy ORM models (DB schema)
│   │   ├── __init__.py
│   │   ├── base.py           # DeclarativeBase
│   │   ├── user.py
│   │   └── item.py
│   ├── schemas/              # Pydantic models (API contracts)
│   │   ├── __init__.py
│   │   ├── user.py
│   │   └── item.py
│   ├── routers/              # APIRouter modules (thin — delegate to services)
│   │   ├── __init__.py
│   │   ├── users.py
│   │   └── items.py
│   ├── services/             # business logic (testable without HTTP)
│   │   ├── __init__.py
│   │   ├── user_service.py
│   │   └── item_service.py
│   └── middleware/           # custom ASGI middleware
│       └── __init__.py
├── migrations/               # Alembic
│   ├── env.py
│   └── versions/
├── tests/
│   ├── conftest.py           # fixtures: async client, test DB session
│   ├── test_users.py
│   └── test_items.py
├── alembic.ini
├── pyproject.toml
└── .env
```

Key rules:
- **`models/`** = SQLAlchemy ORM classes (database representation). **`schemas/`** = Pydantic models (API request/response contracts). Never mix these.
- Keep routers thin — validate input via Pydantic, delegate logic to services, return responses.
- For small projects (< 5 endpoints), a flat layout is fine. Don't create empty directories preemptively.

---

## 2. Application Factory & Lifespan

Use the `lifespan` context manager (not deprecated `on_startup`/`on_shutdown` events) for startup/shutdown logic.

```python
from contextlib import asynccontextmanager
from fastapi import FastAPI
from app.config import settings
from app.database import engine

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: initialize DB pool, cache connections, etc.
    yield
    # Shutdown: dispose engine, close connections
    await engine.dispose()

def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.PROJECT_NAME,
        version=settings.VERSION,
        lifespan=lifespan,
        docs_url="/docs" if settings.ENVIRONMENT != "production" else None,
    )
    # Register routers
    from app.routers import users, items
    app.include_router(users.router, prefix="/api/v1")
    app.include_router(items.router, prefix="/api/v1")

    # Register exception handlers
    from app.exceptions import register_exception_handlers
    register_exception_handlers(app)

    return app

app = create_app()
```

Key rules:
- Disable `/docs` and `/redoc` in production via settings.
- Use `create_app()` factory for testability (allows different configs per test).
- Import routers inside the factory to avoid circular imports.

---

## 3. Configuration with pydantic-settings

Use `BaseSettings` for all configuration. Never hardcode secrets or connection strings.

```python
from pydantic import Field, SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
    )

    # App
    PROJECT_NAME: str = "MyAPI"
    VERSION: str = "0.1.0"
    ENVIRONMENT: str = "development"  # development | staging | production
    DEBUG: bool = False

    # Database
    DATABASE_URL: str = "postgresql+asyncpg://localhost/mydb"

    # Auth
    SECRET_KEY: SecretStr
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # CORS
    ALLOWED_ORIGINS: list[str] = ["http://localhost:3000"]

settings = Settings()
```

Key rules:
- Use `SecretStr` for passwords, API keys, tokens — prevents accidental logging.
- Validate at startup: if a required env var is missing, the app fails immediately with a clear Pydantic error.
- Use `env_prefix` for nested services (e.g., `DB_HOST`, `REDIS_URL`).
- Never commit `.env` files. Provide `.env.example` with placeholder values.

---

## 4. Pydantic Schemas (API Contracts)

Separate schemas for create, update, and response. Use inheritance to reduce duplication.

```python
from datetime import datetime
from pydantic import BaseModel, Field, ConfigDict

# Shared fields
class ItemBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    description: str | None = None

# Create request — only writable fields
class ItemCreate(ItemBase):
    pass

# Update request — all fields optional
class ItemUpdate(BaseModel):
    title: str | None = Field(None, min_length=1, max_length=255)
    description: str | None = None

# Response — includes DB-generated fields
class ItemResponse(ItemBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: datetime
    updated_at: datetime
```

Key rules:
- **Always** set `from_attributes=True` (formerly `orm_mode`) on response schemas so they can serialize ORM objects directly.
- Use `Field(...)` with constraints (`min_length`, `ge`, `le`, `pattern`) for input validation — this is your first line of defense.
- Use `field_validator` / `model_validator` for cross-field or complex validation logic.
- For partial updates, make all fields `Optional` on the update schema and filter out `None` values before applying (use `model.model_dump(exclude_unset=True)`).
- Use `Annotated` types for reusable field definitions when the same constraints appear in multiple schemas.

---

## 5. SQLAlchemy Models (Database Layer)

Use SQLAlchemy 2.0 style with `Mapped` type annotations and async session.

```python
from datetime import datetime
from sqlalchemy import String, func
from sqlalchemy.ext.asyncio import AsyncAttrs
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column

class Base(AsyncAttrs, DeclarativeBase):
    pass

class TimestampMixin:
    created_at: Mapped[datetime] = mapped_column(server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        server_default=func.now(), onupdate=func.now()
    )

class Item(TimestampMixin, Base):
    __tablename__ = "items"

    id: Mapped[int] = mapped_column(primary_key=True)
    title: Mapped[str] = mapped_column(String(255))
    description: Mapped[str | None]
```

Key rules:
- Use `Mapped[]` type annotations (SQLAlchemy 2.0), not legacy `Column()`.
- Include `AsyncAttrs` on `Base` for safe async attribute access.
- Use `server_default=func.now()` — not Python-side defaults — for timestamps so the DB generates them consistently.
- Create mixins for cross-cutting columns (timestamps, soft-delete, audit fields).
- Use Alembic for all schema migrations. Never call `create_all()` in production.

---

## 6. Async Database Session

```python
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from app.config import settings

engine = create_async_engine(
    settings.DATABASE_URL,
    echo=settings.DEBUG,
    pool_size=20,
    max_overflow=10,
    pool_pre_ping=True,
)

AsyncSessionLocal = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)

async def get_db() -> AsyncSession:
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
```

Key rules:
- **`expire_on_commit=False`** — prevents lazy-load exceptions after commit in async context.
- **`pool_pre_ping=True`** — detects stale connections before using them.
- The `get_db` dependency handles commit/rollback. Routers and services don't call `session.commit()` directly.
- Use `selectinload()` or `joinedload()` for eager loading relationships — lazy loading raises errors in async.

---

## 7. Dependency Injection

FastAPI's `Depends()` is the backbone of the architecture. Layer dependencies cleanly.

```python
from typing import Annotated
from fastapi import Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

# DB session dependency
DBSession = Annotated[AsyncSession, Depends(get_db)]

# Auth dependency
async def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)],
    db: DBSession,
) -> User:
    user = await user_service.get_by_token(db, token)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user

CurrentUser = Annotated[User, Depends(get_current_user)]

# Permission dependency (composable)
def require_role(role: str):
    async def check(user: CurrentUser) -> User:
        if user.role != role:
            raise HTTPException(status_code=403, detail="Insufficient permissions")
        return user
    return check

AdminUser = Annotated[User, Depends(require_role("admin"))]
```

Key rules:
- Use `Annotated` type aliases for commonly injected dependencies — cleaner signatures and reusable.
- Dependencies compose: `get_current_user` depends on `get_db`, `require_role` depends on `get_current_user`.
- Keep dependencies pure and focused — one responsibility per dependency.
- Use `dependency_overrides` in tests to swap real dependencies for mocks/stubs.

---

## 8. Routers (Thin Controllers)

Routers handle HTTP concerns only. Business logic lives in services.

```python
from fastapi import APIRouter, status
from app.dependencies import DBSession, CurrentUser
from app.schemas.item import ItemCreate, ItemResponse, ItemUpdate
from app.services import item_service

router = APIRouter(prefix="/items", tags=["items"])

@router.get("/", response_model=list[ItemResponse])
async def list_items(
    db: DBSession,
    skip: int = 0,
    limit: int = 100,
):
    return await item_service.get_items(db, skip=skip, limit=limit)

@router.post("/", response_model=ItemResponse, status_code=status.HTTP_201_CREATED)
async def create_item(
    item_in: ItemCreate,
    db: DBSession,
    user: CurrentUser,
):
    return await item_service.create_item(db, item_in, owner_id=user.id)

@router.get("/{item_id}", response_model=ItemResponse)
async def get_item(item_id: int, db: DBSession):
    item = await item_service.get_item(db, item_id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item

@router.patch("/{item_id}", response_model=ItemResponse)
async def update_item(
    item_id: int,
    item_in: ItemUpdate,
    db: DBSession,
    user: CurrentUser,
):
    return await item_service.update_item(
        db, item_id, item_in.model_dump(exclude_unset=True), user_id=user.id
    )
```

Key rules:
- Always set `response_model` — it filters and validates outgoing data, documents the API, and prevents leaking internal fields.
- Always set explicit `status_code` for non-200 responses (especially 201 for POST).
- Use `PATCH` with partial updates (`exclude_unset=True`), `PUT` for full replacement.
- Use `tags` on routers for auto-grouped OpenAPI docs.
- Use `HTTPException` for HTTP-level errors. Domain-level errors should be raised by services and caught by exception handlers.

---

## 9. Service Layer (Business Logic)

Services are plain async functions or classes. No HTTP knowledge.

```python
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.item import Item
from app.schemas.item import ItemCreate

async def get_items(
    db: AsyncSession, skip: int = 0, limit: int = 100
) -> list[Item]:
    result = await db.scalars(
        select(Item).offset(skip).limit(limit)
    )
    return list(result.all())

async def get_item(db: AsyncSession, item_id: int) -> Item | None:
    return await db.get(Item, item_id)

async def create_item(
    db: AsyncSession, item_in: ItemCreate, owner_id: int
) -> Item:
    item = Item(**item_in.model_dump(), owner_id=owner_id)
    db.add(item)
    await db.flush()  # get the ID without committing (commit in get_db)
    await db.refresh(item)
    return item

async def update_item(
    db: AsyncSession, item_id: int, data: dict, user_id: int
) -> Item:
    item = await db.get(Item, item_id)
    if not item:
        raise ItemNotFoundError(item_id)
    if item.owner_id != user_id:
        raise PermissionDeniedError()
    for key, value in data.items():
        setattr(item, key, value)
    await db.flush()
    await db.refresh(item)
    return item
```

Key rules:
- Use `db.flush()` + `db.refresh()` inside services — the session dependency handles `commit()`.
- Raise domain-specific exceptions (not `HTTPException`) from services. Map them to HTTP responses in exception handlers.
- Services accept Pydantic schemas or plain dicts — never raw `Request` objects.
- For complex queries, use `select()` with SQLAlchemy 2.0 style, not legacy `session.query()`.

---

## 10. Error Handling

Define domain exceptions and map them to HTTP responses centrally.

```python
# app/exceptions.py
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

class AppError(Exception):
    """Base for all domain errors."""
    def __init__(self, detail: str = "An error occurred"):
        self.detail = detail

class NotFoundError(AppError):
    def __init__(self, resource: str, id: int | str):
        super().__init__(f"{resource} {id} not found")
        self.resource = resource
        self.id = id

class PermissionDeniedError(AppError):
    def __init__(self, detail: str = "Permission denied"):
        super().__init__(detail)

class ConflictError(AppError):
    def __init__(self, detail: str = "Resource conflict"):
        super().__init__(detail)

def register_exception_handlers(app: FastAPI):
    @app.exception_handler(NotFoundError)
    async def not_found_handler(request: Request, exc: NotFoundError):
        return JSONResponse(status_code=404, content={"detail": exc.detail})

    @app.exception_handler(PermissionDeniedError)
    async def permission_denied_handler(request: Request, exc: PermissionDeniedError):
        return JSONResponse(status_code=403, content={"detail": exc.detail})

    @app.exception_handler(ConflictError)
    async def conflict_handler(request: Request, exc: ConflictError):
        return JSONResponse(status_code=409, content={"detail": exc.detail})
```

Key rules:
- Keep a consistent error response shape: `{"detail": "..."}` matches FastAPI's built-in `HTTPException` format.
- Log unexpected exceptions (500s) with stack traces. Don't log expected business errors.
- Use FastAPI's `RequestValidationError` handler override if you need custom 422 formatting.

---

## 11. Security & Authentication

```python
from fastapi import Depends
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)

def create_access_token(data: dict, expires_delta: timedelta) -> str:
    to_encode = data.copy()
    to_encode["exp"] = datetime.utcnow() + expires_delta
    return jwt.encode(to_encode, settings.SECRET_KEY.get_secret_value(), algorithm="HS256")
```

Key rules:
- Use `bcrypt` for password hashing — never MD5/SHA.
- JWT tokens for stateless auth. Store only the user ID (`sub`) in the token payload.
- CORS: explicitly list allowed origins — never use `allow_origins=["*"]` with `allow_credentials=True`.
- Rate limit authentication endpoints (use `slowapi` or middleware).
- All secrets via `SecretStr` in settings — call `.get_secret_value()` only where needed.

---

## 12. Testing

Use `pytest` + `httpx.AsyncClient` with dependency overrides.

```python
import pytest
from httpx import AsyncClient, ASGITransport
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from app.main import create_app
from app.database import get_db
from app.models.base import Base

TEST_DATABASE_URL = "sqlite+aiosqlite:///./test.db"

@pytest.fixture
async def db_session():
    engine = create_async_engine(TEST_DATABASE_URL)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    session_factory = async_sessionmaker(engine, expire_on_commit=False)
    async with session_factory() as session:
        yield session
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    await engine.dispose()

@pytest.fixture
async def client(db_session):
    app = create_app()
    app.dependency_overrides[get_db] = lambda: db_session
    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test",
    ) as ac:
        yield ac
    app.dependency_overrides.clear()

@pytest.mark.anyio
async def test_create_item(client):
    response = await client.post("/api/v1/items/", json={
        "title": "Test Item",
        "description": "A test",
    })
    assert response.status_code == 201
    data = response.json()
    assert data["title"] == "Test Item"
    assert "id" in data
```

Key rules:
- Use `httpx.AsyncClient` with `ASGITransport` — not the deprecated `TestClient` for async apps.
- Override `get_db` to inject a test database session. This keeps tests isolated.
- Use a separate test database — SQLite with `aiosqlite` for speed, or a test PostgreSQL instance for integration tests.
- Use `pytest-anyio` or `pytest-asyncio` for async test support.
- Test behavior (HTTP status codes, response shapes), not implementation details.
- Use factory fixtures for creating test data (e.g., `create_test_user()`).

---

## 13. Middleware & CORS

```python
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE"],
    allow_headers=["*"],
)

# In production, restrict trusted hosts
if settings.ENVIRONMENT == "production":
    app.add_middleware(
        TrustedHostMiddleware,
        allowed_hosts=settings.ALLOWED_HOSTS,
    )
```

Key rules:
- Add CORS middleware early — it must wrap all routes.
- Use `TrustedHostMiddleware` in production to prevent host header attacks.
- For custom middleware, prefer pure ASGI middleware over Starlette's `BaseHTTPMiddleware` for performance.
- Add request ID middleware for traceability in logs.

---

## 14. Performance

- Use `async def` for all route handlers and dependencies that perform I/O (DB, HTTP calls, file I/O).
- Use plain `def` only for CPU-bound handlers — FastAPI runs them in a thread pool automatically.
- Use `selectinload()` / `joinedload()` to avoid N+1 queries. Never rely on lazy loading in async.
- Use `BackgroundTasks` for non-critical work (sending emails, webhooks) — don't block the response.
- Use pagination on all list endpoints. Default limit with a max cap (e.g., `limit: int = Query(default=20, le=100)`).
- Use database indexes on columns used in `WHERE`, `ORDER BY`, and foreign keys.
- For heavy background jobs, use a task queue (Celery, Taskiq, ARQ) — not `BackgroundTasks`.

---

## 15. Logging & Observability

```python
import logging
from app.config import settings

logging.basicConfig(
    level=logging.DEBUG if settings.DEBUG else logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)
logger = logging.getLogger(__name__)
```

Key rules:
- Use stdlib `logging` — it integrates with uvicorn and third-party libraries.
- Use structured logging (JSON) in production via `python-json-logger` or `structlog`.
- Log at boundaries: incoming requests, outgoing responses, external service calls, errors.
- Never log secrets, tokens, passwords, or full request bodies containing PII.

---

## 16. API Versioning

Prefer URL prefix versioning (`/api/v1/`, `/api/v2/`) — it's explicit and easy to manage with routers.

```python
v1_router = APIRouter(prefix="/api/v1")
v1_router.include_router(users.router)
v1_router.include_router(items.router)

app.include_router(v1_router)
```

When introducing v2: create new router modules, keep v1 stable, deprecate with `deprecated=True` on old routers.

---

## Quick Reference: Dependencies to Use

| Package | Purpose |
|---|---|
| `fastapi` | Web framework |
| `uvicorn[standard]` | ASGI server |
| `pydantic[email]` | Validation + email type |
| `pydantic-settings` | Config from env / .env |
| `sqlalchemy[asyncio]` | Async ORM |
| `asyncpg` | PostgreSQL async driver |
| `aiosqlite` | SQLite async driver (dev/test) |
| `alembic` | Database migrations |
| `python-jose[cryptography]` | JWT tokens |
| `passlib[bcrypt]` | Password hashing |
| `httpx` | Async HTTP client + testing |
| `pytest-anyio` | Async test runner |
