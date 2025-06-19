# 글쓰기/수정 폼
# 사용자가 글 작성/수정할 때 사용할 폼
from django import forms
from .models import Post, Comment


class PostForm(forms.ModelForm):
    class Meta:
        model = Post
        fields = ["title", "content"]


class CommentForm(forms.ModelForm):
    class Meta:
        model = Comment
        fields = ["author", "text"]
