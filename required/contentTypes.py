#!/usr/bin/env python
from django_proj*.wsgi import *
from django.contrib.contenttypes.models import ContentType
ContentType.objects.all().delete()
