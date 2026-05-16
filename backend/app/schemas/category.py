from pydantic import BaseModel, Field
from uuid import UUID


class CategoryCreate(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    icon: str = "tag"
    color: str = Field(default="#6366f1", pattern=r"^#[0-9A-Fa-f]{6}$")


class CategoryUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=100)
    icon: str | None = None
    color: str | None = Field(default=None, pattern=r"^#[0-9A-Fa-f]{6}$")


class CategoryResponse(BaseModel):
    id: UUID
    user_id: UUID | None
    name: str
    icon: str
    color: str
    is_system: bool

    class Config:
        from_attributes = True
