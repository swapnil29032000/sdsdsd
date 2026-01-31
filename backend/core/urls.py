from django.urls import path
from django.http import HttpResponse
from .views import hello_world

urlpatterns = [
    path('', lambda request: HttpResponse("API is running 🚀")),
    path('hello/', hello_world, name='hello_world'),
]
