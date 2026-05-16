import json
import asyncio
import google.generativeai as genai
from app.config import settings

genai.configure(api_key=settings.GEMINI_API_KEY)
_model = genai.GenerativeModel("gemini-1.5-flash")

_SYSTEM_CATEGORIES = ["Market", "Ulaşım", "Faturalar", "Yeme-İçme", "Sağlık", "Eğlence", "Diğer"]

_PROMPT = f"""Bu bir Türkçe fiş veya fatura fotoğrafıdır. Fişten aşağıdaki bilgileri çıkar ve SADECE geçerli JSON döndür:

{{
  "merchant": "işletme/market adı veya null",
  "total_amount": toplam_tutar_sayı_veya_null,
  "receipt_date": "YYYY-MM-DD formatında tarih veya null",
  "items": [
    {{
      "name": "ürün adı",
      "quantity": miktar_sayı_veya_null,
      "unit_price": birim_fiyat_sayı_veya_null,
      "total": toplam_fiyat_sayı_veya_null,
      "category": "şu kategorilerden biri: {', '.join(_SYSTEM_CATEGORIES)}"
    }}
  ]
}}

Her ürün için category alanını şu kategorilerden birine ata: {', '.join(_SYSTEM_CATEGORIES)}.
Eğer ürün hangi kategoriye girdiği belirsizse "Diğer" kullan.
Başka metin, açıklama veya markdown ekleme. Sadece JSON."""


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
