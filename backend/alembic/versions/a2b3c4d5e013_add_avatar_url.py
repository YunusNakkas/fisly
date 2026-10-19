"""add avatar_url to users

Revision ID: a2b3c4d5e013
Revises: a1b2c3d4e012
Create Date: 2026-05-21 00:30:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa


revision: str = "a2b3c4d5e013"
down_revision: Union[str, None] = "a1b2c3d4e012"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "users",
        sa.Column("avatar_url", sa.String(length=500), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("users", "avatar_url")
