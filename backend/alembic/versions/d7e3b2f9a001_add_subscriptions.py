"""add subscriptions table

Revision ID: d7e3b2f9a001
Revises: c4d2f1a8e003
Create Date: 2026-05-07 22:00:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = "d7e3b2f9a001"
down_revision: Union[str, None] = "c4d2f1a8e003"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    period_enum = postgresql.ENUM("weekly", "monthly", "yearly", name="period")
    period_enum.create(op.get_bind(), checkfirst=True)

    status_enum = postgresql.ENUM("active", "cancelled", name="subscriptionstatus")
    status_enum.create(op.get_bind(), checkfirst=True)

    op.create_table(
        "subscriptions",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("category_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("categories.id"), nullable=True),
        sa.Column("name", sa.String(255), nullable=False),
        sa.Column("amount", sa.Numeric(12, 2), nullable=False),
        sa.Column("currency", sa.String(3), nullable=False, server_default="TRY"),
        sa.Column("period", postgresql.ENUM(name="period", create_type=False), nullable=False),
        sa.Column("start_date", sa.Date, nullable=False),
        sa.Column("next_billing_date", sa.Date, nullable=False),
        sa.Column("status", postgresql.ENUM(name="subscriptionstatus", create_type=False), nullable=False, server_default="active"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_subscriptions_user_billing", "subscriptions", ["user_id", "next_billing_date"])


def downgrade() -> None:
    op.drop_index("ix_subscriptions_user_billing")
    op.drop_table("subscriptions")
    sa.Enum(name="period").drop(op.get_bind(), checkfirst=True)
    sa.Enum(name="subscriptionstatus").drop(op.get_bind(), checkfirst=True)
