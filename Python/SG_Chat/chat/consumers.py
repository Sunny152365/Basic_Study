# chat/consumers.py
import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
# 최상단에 models 임포트 제거해서 앱 초기화 문제 방지

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        # URL에서 방 이름(room_name) 받기 (예: /ws/chat/<room_name>/)
        self.room_name = self.scope['url_route']['kwargs']['room_name']
        self.room_group_name = f'chat_{self.room_name}'

        # 그룹에 참가
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )
        await self.accept()

    async def disconnect(self, close_code):
        # 그룹에서 나가기
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )

    # WebSocket으로부터 메시지 받기
    async def receive(self, text_data):
        data = json.loads(text_data)
        message = data['message']
        user = self.scope["user"]  # 인증된 사용자 객체

        # DB에 메시지 저장 (비동기-동기 변환)
        await self.save_message(user.id, self.room_name, message)

        # 그룹에 메시지 브로드캐스트
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'chat_message',  # 처리 메서드 이름
                'message': message,
                'user': user.username  # username으로 보내줘야 사용자 이름 출력됨
            }
        )

    # 그룹에서 받은 메시지를 WebSocket으로 전송
    async def chat_message(self, event):
        message = event['message']
        user = event['user']

        await self.send(text_data=json.dumps({
            'message': message,
            'user': user
        }))

    @database_sync_to_async
    def save_message(self, user_id, room_name, message):
        # User 모델은 함수 내부에서 동적으로 import (Apps ready 에러 방지)
        from .models import ChatRoom, Message
        from django.contrib.auth import get_user_model
        User = get_user_model()

        # room_name이 실제로는 room_id임
        room = ChatRoom.objects.get(id=room_name)
        user = User.objects.get(id=user_id)
        return Message.objects.create(sender=user, room=room, content=message)
