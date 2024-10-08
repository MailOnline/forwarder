FROM python:2.7.18

RUN apt-get update -y && \
    apt-get install -y zip unzip netcat

RUN mkdir /app
WORKDIR /app

CMD ["./run_tests.sh", "-p"]
