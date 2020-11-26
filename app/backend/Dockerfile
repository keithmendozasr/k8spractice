FROM python:3.7-alpine AS build

RUN apk update
RUN apk add libpq gcc postgresql-dev musl-dev

WORKDIR /app
COPY k8spayload k8spayload/
COPY requirements.txt ./
RUN pip3 install -r requirements.txt
RUN pip3 install gunicorn
RUN apk del gcc postgresql-dev musl-dev

ENTRYPOINT [ "gunicorn", "--workers=1", "--bind=0.0.0.0:5000", "k8spayload:app" ]
