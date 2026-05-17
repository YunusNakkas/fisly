"""Async email service.

If SMTP_HOST is empty, emails are written to logs in development mode.
SMTP environment variables must be set in production.
"""
import logging
from email.message import EmailMessage
from app.config import settings

logger = logging.getLogger("fisly.email")

_TEMPLATES = {
    "password_reset": {
        "subject": "Fisly password reset",
        "body": (
            "Hello,\n\n"
            "We received a password reset request for your Fisly account.\n\n"
            "Click the link below or enter the token in the app:\n\n"
            "{app_url}/reset-password?token={token}\n\n"
            "Token: {token}\n\n"
            "The link expires in 30 minutes. "
            "If you did not request this, you can ignore this email.\n\n"
            "- Fisly"
        ),
    },
}


async def send_password_reset(email: str, token: str) -> None:
    template = _TEMPLATES["password_reset"]
    body = template["body"].format(app_url=settings.APP_URL, token=token)
    await _send(email, template["subject"], body)


async def _send(to: str, subject: str, body: str) -> None:
    if not settings.SMTP_HOST:
        logger.warning(
            "EMAIL (SMTP not configured) → %s\nSubject: %s\n\n%s",
            to, subject, body,
        )
        return

    try:
        import aiosmtplib
    except ImportError:
        logger.error("aiosmtplib is not installed - email could not be sent: %s", to)
        return

    msg = EmailMessage()
    msg["From"] = settings.SMTP_FROM
    msg["To"] = to
    msg["Subject"] = subject
    msg.set_content(body)

    try:
        await aiosmtplib.send(
            msg,
            hostname=settings.SMTP_HOST,
            port=settings.SMTP_PORT,
            username=settings.SMTP_USER or None,
            password=settings.SMTP_PASSWORD or None,
            start_tls=settings.SMTP_USE_TLS,
        )
        logger.info("Email sent: %s (%s)", to, subject)
    except Exception as e:
        logger.exception("Email could not be sent (%s): %s", to, e)
