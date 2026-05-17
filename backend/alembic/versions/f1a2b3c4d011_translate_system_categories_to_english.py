"""translate system categories to english

Revision ID: f1a2b3c4d011
Revises: c3d4e5f6a010
Create Date: 2026-05-16 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "f1a2b3c4d011"
down_revision: Union[str, None] = "c3d4e5f6a010"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


TR_TO_EN = {
    "Market": "Groceries",
    "Ulaşım": "Transportation",
    "Faturalar": "Bills",
    "Yeme-İçme": "Food & Drink",
    "Sağlık": "Health",
    "Eğlence": "Entertainment",
    "Diğer": "Other",
}

EN_TO_TR = {value: key for key, value in TR_TO_EN.items()}


def _rename(mapping: dict[str, str]) -> None:
    bind = op.get_bind()
    for old, new in mapping.items():
        bind.execute(
            sa.text(
                """
            UPDATE categories
            SET name = :new
            WHERE is_system = TRUE
              AND user_id IS NULL
              AND name = :old
            """
            ),
            {"old": old, "new": new},
        )


def upgrade() -> None:
    _rename(TR_TO_EN)


def downgrade() -> None:
    _rename(EN_TO_TR)
