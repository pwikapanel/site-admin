
#————————————————————————————————————————

EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'localhost'
EMAIL_PORT = 25
EMAIL_HOST_USER = ''
EMAIL_HOST_PASSWORD = ''
EMAIL_USE_TLS = False

import os
TEMPLATES[0]['DIRS']  =  [os.path.join(BASE_DIR, 'templates')]
STATIC_ROOT = os.path.join(BASE_DIR, 'static/')
INSTALLED_APPS.insert(0, 'svija')
INSTALLED_APPS.insert(0, 'ckeditor')
MIDDLEWARE.insert(0, 'django.middleware.locale.LocaleMiddleware')

DATABASES = { 
    'default': {
        'ENGINE'  : 'django.db.backends.postgresql_psycopg2',
        'NAME'    : 'django_proj*db',
        'USER'    : 'django_proj*user',
        'PASSWORD': 'django_pw*',
        'HOST'    : 'localhost',
        'PORT'    : '', 
    }   
}

CACHES = {
    'default': {
        'BACKEND' : 'django.core.cache.backends.filebased.FileBasedCache',
#       'LOCATION': '/home/django_proj*/cache',
        'LOCATION': os.path.join(BASE_DIR, 'cache') 
    }
}

X_FRAME_OPTIONS = 'SAMEORIGIN'
APPEND_SLASH = False

TIME_ZONE = 'time_zone*'
ALLOWED_HOSTS = ['url*',]

DEBUG = False
