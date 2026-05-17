"""add revoked tokens table

Revision ID: b2c3d4e5f009
Revises: a1b2c3d4e008
Create Date: 2026-05-16 00:10:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa


revision: str = "b2c3d4e5f009"
down_revision: Union[str, None] = "a1b2c3d4e008"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "revoked_tokens",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("jti", sa.String(length=64), nullable=False),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("revoked_at", sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_revoked_tokens_jti"), "revoked_tokens", ["jti"], unique=True)


def downgrade() -> None:
    op.drop_index(op.f("ix_revoked_tokens_jti"), table_name="revoked_tokens")
    op.drop_table("revoked_tokens")
