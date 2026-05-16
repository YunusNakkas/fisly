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

    class Config:
        env_file = ".env"


settings = Settings()
