from fastapi import FastAPI
from app.core.config import settings
from app.routes.tasks import router as tasks_router

app = FastAPI(title=settings.app_name, version=settings.app_version)
app.include_router(tasks_router, prefix="/api")
