from django.contrib import admin
from django.urls import path, re_path, include

urlpatterns = [
    path('cloud/', admin.site.urls),
    re_path(r'^', include('svija.urls', namespace="svija")),
]

handler404 = 'svija.views.Error404'
