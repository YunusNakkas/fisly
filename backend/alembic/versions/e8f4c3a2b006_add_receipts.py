"""add receipts

Revision ID: e8f4c3a2b006
Revises: d7e3b2f9a001
Create Date: 2026-05-08
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision: str = "e8f4c3a2b006"
down_revision: str = "d7e3b2f9a001"
branch_labels = None
depends_on = None


def upgrade() -> None:
    receipt_status = postgresql.ENUM(
        "pending", "parsed", "failed", "manual",
        name="receiptstatus",
    )
    receipt_status.create(op.get_bind(), checkfirst=True)

    op.create_table(
        "receipts",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("image_url", sa.String(500), nullable=False),
        sa.Column("raw_ocr_data", postgresql.JSONB(), nullable=True),
        sa.Column("merchant", sa.String(255), nullable=True),
        sa.Column("total_amount", sa.Numeric(12, 2), nullable=True),
        sa.Column("receipt_date", sa.Date(), nullable=True),
        sa.Column("status", postgresql.ENUM(name="receiptstatus", create_type=False), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
    )


def downgrade() -> None:
    op.drop_table("receipts")
    op.execute("DROP TYPE receiptstatus")
