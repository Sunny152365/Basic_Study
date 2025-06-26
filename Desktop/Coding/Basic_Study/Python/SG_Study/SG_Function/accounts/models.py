from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    # 추후 확장을 위해 커스텀 유저 모델 설정
    phone = models.CharField(max_length=20, blank=True)
    is_expert = models.BooleanField(default=False)
