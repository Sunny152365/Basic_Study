from django.shortcuts import render, redirect, get_object_or_404
from .models import Post, Comment
from .forms import PostForm, CommentForm  # 나중에 만들 폼

def post_list(request):
    posts = Post.objects.all().order_by('-created_at') # 최신 글부터 정렬
    return render(request, 'blog/post_list.html', {'posts': posts})

# Create (글쓰기)
def post_new(request):
    if request.method == "POST":
        form = PostForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect('post_list')
    else:
        form = PostForm()
    return render(request, 'blog/post_edit.html', {'form': form})

# Read (글 목록 & 상세보기)
def post_detail(request, pk):
    print(f"post_detail 호출 - method: {request.method}")
    post = get_object_or_404(Post, pk=pk)
    comments = post.comments.all()

    if request.method == 'POST':
        form = CommentForm(request.POST)
        print("폼 데이터:", request.POST)  # 이걸로 데이터가 넘어오는지 확인
        if form.is_valid():
            comment = form.save(commit=False)
            comment.post = post
            comment.save()
            print("댓글 저장됨:", comment)
            return redirect('post_detail', pk=pk)
        else:
            print("폼 오류:", form.errors)  # 폼 오류 출력
    else:
        form = CommentForm()

    return render(request, 'blog/post_detail.html', {'post': post, 'comments': comments, 'form': form})

# Update (글 수정)
def post_edit(request, pk):
    post = get_object_or_404(Post, pk=pk)
    if request.method == "POST":
        form = PostForm(request.POST, instance=post)
        if form.is_valid():
            form.save()
            return redirect('post_detail', pk=post.pk)
    else:
        form = PostForm(instance=post)
    return render(request, 'blog/post_edit.html', {'form': form})

# Delete (글 삭제)
def post_delete(request, pk):
    post = get_object_or_404(Post, pk=pk)
    if request.method == "POST":
        post.delete()
        return redirect('post_list')
    return render(request, 'blog/post_delete_confirm.html', {'post': post})
