"""add password resets table

Revision ID: a1b2c3d4e008
Revises: f9a5d8b1c007
Create Date: 2026-05-16 00:00:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa


revision: str = "a1b2c3d4e008"
down_revision: Union[str, None] = "f9a5d8b1c007"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "password_resets",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("token_hash", sa.String(length=255), nullable=False),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("used", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_password_resets_user_id"), "password_resets", ["user_id"])
    op.create_index(op.f("ix_password_resets_token_hash"), "password_resets", ["token_hash"], unique=True)


def downgrade() -> None:
    op.drop_index(op.f("ix_password_resets_token_hash"), table_name="password_resets")
    op.drop_index(op.f("ix_password_resets_user_id"), table_name="password_resets")
    op.drop_table("password_resets")
