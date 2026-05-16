"""add feedbacks table

Revision ID: c4d2f1a8e003
Revises: 8a3f1c9b2e10
Create Date: 2026-05-07 21:30:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = "c4d2f1a8e003"
down_revision: Union[str, None] = "8a3f1c9b2e10"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    feedback_kind = postgresql.ENUM(
        "bug", "suggestion", "complaint", "other",
        name="feedbackkind",
    )
    feedback_kind.create(op.get_bind(), checkfirst=True)

    op.create_table(
        "feedbacks",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("kind", postgresql.ENUM(name="feedbackkind", create_type=False), nullable=False, server_default="other"),
        sa.Column("subject", sa.String(255), nullable=False),
        sa.Column("message", sa.Text, nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )


def downgrade() -> None:
    op.drop_table("feedbacks")
    sa.Enum(name="feedbackkind").drop(op.get_bind(), checkfirst=True)
