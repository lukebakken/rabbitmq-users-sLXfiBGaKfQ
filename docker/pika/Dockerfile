FROM python:3

WORKDIR /app

RUN pip install pika
RUN mkdir -p certs/rmq-1

COPY client.py .
COPY certs/ca_certs.pem certs/
COPY certs/rmq-1/client_rmq-1_certificate.pem certs/rmq-1
COPY certs/rmq-1/client_rmq-1_key.pem certs/rmq-1

CMD ["python", "client.py"]
