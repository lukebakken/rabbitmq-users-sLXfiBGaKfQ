FROM python:3

WORKDIR /app

COPY client.py .
COPY certs/rmq-1/ca_certificate.pem .
COPY certs/rmq-1/client_rmq-1_certificate.pem .
COPY certs/rmq-1/client_rmq-1_key.pem .

RUN pip install pika

CMD ["python", "./client.py"]
