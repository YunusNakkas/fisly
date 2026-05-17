import json
import logging
import os
from logging.handlers import RotatingFileHandler
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from app.core.limiter import limiter
from app.config import settings
from app.routers import auth, expenses, categories, feedback, reports, subscriptions, receipts, admin, budgets
from app.models import (
    user, category, expense, feedback as _feedback_model, subscription,
    receipt as _receipt_model, budget as _budget_model,
    password_reset as _password_reset_model,
    revoked_token as _revoked_token_model,
    receipt_item as _receipt_item_model,
)  # For SQLAlchemy metadata
from fastapi.responses import JSONResponse
import time

# Initialize Sentry when a DSN is configured.
if settings.SENTRY_DSN:
    import sentry_sdk
    sentry_sdk.init(
        dsn=settings.SENTRY_DSN,
        environment=settings.ENV,
        traces_sample_rate=0.1,
        send_default_pii=False,
    )

os.makedirs("logs", exist_ok=True)

_fmt = logging.Formatter(
    "%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

_file_handler = RotatingFileHandler(
    "logs/app.log", maxBytes=5 * 1024 * 1024, backupCount=3, encoding="utf-8"
)
_file_handler.setFormatter(_fmt)

logging.root.setLevel(logging.INFO)
logging.root.addHandler(_file_handler)

logger = logging.getLogger("fisly")


class UnicodeJSONResponse(JSONResponse):
    media_type = "application/json; charset=utf-8"

    def render(self, content) -> bytes:
        return json.dumps(content, ensure_ascii=False).encode("utf-8")


app = FastAPI(title="Fişly API", version="0.1.0", default_response_class=UnicodeJSONResponse)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def log_requests(request: Request, call_next):
    start = time.monotonic()
    response = await call_next(request)
    ms = int((time.monotonic() - start) * 1000)
    level = logging.WARNING if response.status_code >= 400 else logging.INFO
    logger.log(
        level,
        "%s %s → %d (%dms)",
        request.method,
        request.url.path,
        response.status_code,
        ms,
    )
    return response


app.include_router(auth.router, prefix="/api/v1")
app.include_router(expenses.router, prefix="/api/v1")
app.include_router(categories.router, prefix="/api/v1")
app.include_router(feedback.router, prefix="/api/v1")
app.include_router(reports.router, prefix="/api/v1")
app.include_router(subscriptions.router, prefix="/api/v1")
app.include_router(receipts.router, prefix="/api/v1")
app.include_router(admin.router, prefix="/api/v1")
app.include_router(budgets.router, prefix="/api/v1")

os.makedirs("uploads", exist_ok=True)
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")


@app.get("/")
async def root():
    return {"message": "Fisly API is running"}


@app.get("/health")
async def health():
    return {"status": "ok"}
