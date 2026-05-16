from pydantic import BaseModel, Field
from datetime import datetime
from uuid import UUID
from app.models.feedback import FeedbackKind


class FeedbackCreate(BaseModel):
    kind: FeedbackKind = FeedbackKind.other
    subject: str = Field(min_length=1, max_length=255)
    message: str = Field(min_length=1)


class FeedbackResponse(BaseModel):
    id: UUID
    kind: FeedbackKind
    subject: str
    message: str
    created_at: datetime

    class Config:
        from_attributes = True
