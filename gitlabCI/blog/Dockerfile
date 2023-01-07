FROM python:3-alpine
ENV PYTHONUNBUFFERED 1
RUN mkdir /code
WORKDIR /code
ADD requirements.txt /code/
RUN pip install -r requirements.txt
COPY . /code/
#RUN echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', ' admin@admin.ru ', 'pass')" | python3 manage.py shell
#RUN python3 manage.py migrate
CMD sh init.sh && python3 manage.py runserver 0.0.0.0:8000