from django.urls import path
from . import views

urlpatterns = [
    path('', views.post_list, name='post_list'),                  # 목록
    path('post/<int:pk>/', views.post_detail, name='post_detail'), # 상세
    path('post/new/', views.post_new, name='post_new'),            # 글쓰기
    path('post/<int:pk>/edit/', views.post_edit, name='post_edit'), # 수정
    path('post/<int:pk>/delete/', views.post_delete, name='post_delete'), # 삭제
]
