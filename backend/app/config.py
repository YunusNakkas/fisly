# pyrefly: ignore [missing-import]
from pydantic_settings import BaseSettings 


class Settings(BaseSettings):
    DATABASE_URL: str
    SECRET_KEY: str
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30
    GEMINI_API_KEY: str = ""
    ADMIN_TOKEN: str = ""
    FREE_RECEIPT_QUOTA: int = 30

    # Comma-separated list of allowed CORS origins. "*" allows all (dev only).
    CORS_ORIGINS: str = "*"

    # SMTP - emails are logged when empty (dev mode)
    SMTP_HOST: str = ""
    SMTP_PORT: int = 587
    SMTP_USER: str = ""
    SMTP_PASSWORD: str = ""
    SMTP_FROM: str = "noreply@fisly.app"
    SMTP_USE_TLS: bool = True

    # Public app URL - used for password reset links
    APP_URL: str = "https://fisly.app"

    # Sentry DSN - disabled when empty
    SENTRY_DSN: str = ""
    ENV: str = "development"

    @property
    def cors_origins_list(self) -> list[str]:
        if self.CORS_ORIGINS.strip() == "*":
            return ["*"]
        return [o.strip() for o in self.CORS_ORIGINS.split(",") if o.strip()]

    class Config:
        env_file = ".env"


settings = Settings()
