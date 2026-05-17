"""Pytest fixture'ları — SQLite in-memory ile izole testler."""
import os
import sys
import pathlib

# Backend kök dizinini path'e ekle
sys.path.insert(0, str(pathlib.Path(__file__).parent.parent))

# Test env değişkenleri (Settings yüklemesi öncesi)
os.environ.setdefault("DATABASE_URL", "sqlite+aiosqlite:///:memory:")
os.environ.setdefault("SECRET_KEY", "test-secret-key-for-pytest-only")
os.environ.setdefault("GEMINI_API_KEY", "")
os.environ.setdefault("CORS_ORIGINS", "*")

import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession

from app.database import Base, get_db
from app.main import app


@pytest_asyncio.fixture
async def db_engine():
    engine = create_async_engine("sqlite+aiosqlite:///:memory:", echo=False)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield engine
    await engine.dispose()


@pytest_asyncio.fixture
async def db_session(db_engine):
    sessionmaker = async_sessionmaker(db_engine, class_=AsyncSession, expire_on_commit=False)
    async with sessionmaker() as session:
        yield session


@pytest_asyncio.fixture
async def client(db_engine):
    sessionmaker = async_sessionmaker(db_engine, class_=AsyncSession, expire_on_commit=False)

    async def override_get_db():
        async with sessionmaker() as session:
            yield session

    app.dependency_overrides[get_db] = override_get_db
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac
    app.dependency_overrides.clear()
