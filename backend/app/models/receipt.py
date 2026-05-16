import uuid
import enum
from datetime import date, datetime
from decimal import Decimal
from sqlalchemy import String, DateTime, Numeric, ForeignKey, Date, Enum as SAEnum
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column
from app.database import Base


class ReceiptStatus(str, enum.Enum):
    pending = "pending"
    parsed = "parsed"
    failed = "failed"
    manual = "manual"


class Receipt(Base):
    __tablename__ = "receipts"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"))
    image_url: Mapped[str] = mapped_column(String(500))
    raw_ocr_data: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    merchant: Mapped[str | None] = mapped_column(String(255), nullable=True)
    total_amount: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    receipt_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    status: Mapped[ReceiptStatus] = mapped_column(
        SAEnum(ReceiptStatus, name="receiptstatus", create_type=False),
        default=ReceiptStatus.pending,
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow)
