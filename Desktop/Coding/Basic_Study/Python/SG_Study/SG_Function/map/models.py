from django.db import models
from accounts.models import User

class ExpertLocation(models.Model):
    expert = models.OneToOneField(User, on_delete=models.CASCADE)
    latitude = models.FloatField()
    longitude = models.FloatField()
    updated_at = models.DateTimeField(auto_now=True)
