from django.contrib.auth.models import User

username = "cloud_user*"
email = "email*"
password = "cloud_pw*"
User.objects.create_superuser(username, email, password)

user = User.objects.get(username='cloud_user*')
user.first_name='first_name*'
user.last_name='last_name*'
user.save()

from svija.models import Robots, Settings
settings = Settings.objects.filter(enabled=True).first()
settings.url='url*'
#obot = Robots.objects.filter(name='Indexed by Google').first()
robot = Robots.objects.filter(name__icontains='google').first()
settings.robots=robot
settings.save()

exit()
