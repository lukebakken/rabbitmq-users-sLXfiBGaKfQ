FROM python:3

WORKDIR /app

RUN pip install pika
RUN mkdir -p certs/rmq-1

COPY docker/pika/client.py .
COPY ./certificates/rmq-1/ca-chain.cert.pem certs/rmq-1/ca-chain.cert.pem
COPY ./certificates/rmq-1/rmq-1.cert.pem certs/rmq-1/rmq-1.cert.pem
COPY ./certificates/rmq-1/rmq-1.key.pem certs/rmq-1/rmq-1.key.pem

CMD ["python", "client.py"]
