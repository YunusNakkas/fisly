import json
import asyncio
import google.generativeai as genai
from app.config import settings

genai.configure(api_key=settings.GEMINI_API_KEY)
_model = genai.GenerativeModel("gemini-1.5-flash")

_SYSTEM_CATEGORIES = [
    "Groceries",
    "Transportation",
    "Bills",
    "Food & Drink",
    "Health",
    "Entertainment",
    "Other",
]

_PROMPT = f"""This is a Turkish receipt or invoice photo. Extract the following information and return ONLY valid JSON:

{{
  "merchant": "business/store name or null",
  "total_amount": total_amount_number_or_null,
  "receipt_date": "date in YYYY-MM-DD format or null",
  "items": [
    {{
      "name": "item name",
      "quantity": quantity_number_or_null,
      "unit_price": unit_price_number_or_null,
      "total": total_price_number_or_null,
      "category": "one of these categories: {', '.join(_SYSTEM_CATEGORIES)}"
    }}
  ]
}}

Assign the category field for each item to one of these categories: {', '.join(_SYSTEM_CATEGORIES)}.
If the category is unclear, use "Other".
Do not include any other text, explanation or markdown. Only JSON."""


def _clean_json(text: str) -> str:
    text = text.strip()
    if text.startswith("```"):
        parts = text.split("```")
        if len(parts) >= 3:
            text = parts[1]
        elif len(parts) >= 2:
            text = parts[1]
        if text.startswith("json"):
            text = text[4:]
    return text.strip()


async def parse_receipt(image_bytes: bytes, mime_type: str = "image/jpeg") -> dict:
    try:
        part = genai.types.Part.from_bytes(data=image_bytes, mime_type=mime_type)
        response = await asyncio.to_thread(_model.generate_content, [_PROMPT, part])
        raw = _clean_json(response.text)
        return json.loads(raw)
    except Exception:
        return {}
