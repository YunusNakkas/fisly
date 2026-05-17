"""seed system categories

Revision ID: 8a3f1c9b2e10
Revises: 4ec145266796
Create Date: 2026-05-07 19:00:00.000000

"""
from typing import Sequence, Union
from uuid import uuid4

from alembic import op
import sqlalchemy as sa


revision: str = "8a3f1c9b2e10"
down_revision: Union[str, None] = "4ec145266796"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


SYSTEM_CATEGORIES = [
    ("Groceries", "shopping_cart", "#10b981"),
    ("Transportation", "directions_car", "#3b82f6"),
    ("Bills", "receipt_long", "#f59e0b"),
    ("Food & Drink", "restaurant", "#ef4444"),
    ("Health", "local_hospital", "#ec4899"),
    ("Entertainment", "movie", "#8b5cf6"),
    ("Other", "more_horiz", "#6b7280"),
]


def upgrade() -> None:
    categories_table = sa.table(
        "categories",
        sa.column("id", sa.dialects.postgresql.UUID(as_uuid=True)),
        sa.column("user_id", sa.dialects.postgresql.UUID(as_uuid=True)),
        sa.column("name", sa.String),
        sa.column("icon", sa.String),
        sa.column("color", sa.String),
        sa.column("is_system", sa.Boolean),
    )
    op.bulk_insert(
        categories_table,
        [
            {
                "id": uuid4(),
                "user_id": None,
                "name": name,
                "icon": icon,
                "color": color,
                "is_system": True,
            }
            for name, icon, color in SYSTEM_CATEGORIES
        ],
    )


def downgrade() -> None:
    op.execute("DELETE FROM categories WHERE is_system = TRUE AND user_id IS NULL")
