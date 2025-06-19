"""
ASGI config for config project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/5.2/howto/deployment/asgi/
"""

# config/asgi.py
import os
import django
from channels.auth import AuthMiddlewareStack
from channels.routing import ProtocolTypeRouter, URLRouter
from django.core.asgi import get_asgi_application
import chat.routing

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

django_asgi_app = get_asgi_application()

application = ProtocolTypeRouter({
    "http": django_asgi_app,  # HTTP 요청은 기존 Django가 처리 get_asgi_application() -> django_asgi_app 한 번만 호출해서 재사용
    "websocket": AuthMiddlewareStack(  # WebSocket 요청은 Channels가 처리, 인증 미들웨어 포함
        URLRouter(
            chat.routing.websocket_urlpatterns
        )
    ),
})


