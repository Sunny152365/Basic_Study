from django.urls import path
from . import views

urlpatterns = [
    path('', views.post_list, name='post_list'),  # / → 글 목록
    path('post/<int:pk>/', views.post_detail, name='post_detail'),  # /post/1/ → 상세
]
