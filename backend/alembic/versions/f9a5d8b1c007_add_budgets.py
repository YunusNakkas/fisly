"""add budgets table

Revision ID: f9a5d8b1c007
Revises: e8f4c3a2b006
Create Date: 2026-05-14 00:00:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = "f9a5d8b1c007"
down_revision: Union[str, None] = "e8f4c3a2b006"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    period_enum = postgresql.ENUM("weekly", "monthly", name="budgetperiod")
    period_enum.create(op.get_bind(), checkfirst=True)

    op.create_table(
        "budgets",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("category_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("categories.id"), nullable=True),
        sa.Column("amount", sa.Numeric(12, 2), nullable=False),
        sa.Column("period", postgresql.ENUM(name="budgetperiod", create_type=False), nullable=False, server_default="monthly"),
        sa.Column("starts_on", sa.Date, nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("user_id", "category_id", "period", name="uq_budget_user_cat_period"),
    )
    op.create_index("ix_budgets_user", "budgets", ["user_id"])


def downgrade() -> None:
    op.drop_index("ix_budgets_user")
    op.drop_table("budgets")
    sa.Enum(name="budgetperiod").drop(op.get_bind(), checkfirst=True)
