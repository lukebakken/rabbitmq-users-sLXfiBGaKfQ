FROM rabbitmq:3-management

COPY --chown=rabbitmq:rabbitmq --chmod=0400 ./docker/rmq/erlang.cookie /var/lib/rabbitmq/.erlang.cookie
COPY --chown=rabbitmq:rabbitmq ./docker/rmq/enabled_plugins /etc/rabbitmq/
COPY --chown=rabbitmq:rabbitmq ./docker/rmq/rabbitmq.conf /etc/rabbitmq/rabbitmq.conf
COPY --chown=rabbitmq:rabbitmq ./docker/rmq/definitions.json /etc/rabbitmq/

RUN mkdir -p /etc/rabbitmq/certs && chown rabbitmq:rabbitmq /etc/rabbitmq/certs
RUN mkdir -p /etc/rabbitmq/trust_store && chown rabbitmq:rabbitmq /etc/rabbitmq/trust_store

# This only trusts client certs that have been signed by the rmq-0 CA cert
# COPY --chown=rabbitmq:rabbitmq --chmod=0400 ./certs/rmq-0/ca_certificate.pem /etc/rabbitmq/trust_store/rmq-0-ca.pem

# This is if you want all CAs to be trusted
# COPY --chown=rabbitmq:rabbitmq --chmod=0400 ./certs/rmq-0/ca_certificate.pem /etc/rabbitmq/trust_store/rmq-0-ca.pem
# COPY --chown=rabbitmq:rabbitmq --chmod=0400 ./certs/rmq-1/ca_certificate.pem /etc/rabbitmq/trust_store/rmq-1-ca.pem

# NOTE: we only use the rmq-0 CA certificate here. This means that since the client presents a cert signed
# by the rmq-1 CA, it will be rejected UNLESS the rmq-1 CA is in the trust_store dir
COPY --chown=rabbitmq:rabbitmq --chmod=0400 ./certificates/rmq-0/ca-chain.cert.pem /etc/rabbitmq/certs/ca.pem
COPY --chown=rabbitmq:rabbitmq --chmod=0400 ./certificates/rmq-0/server.cert.pem /etc/rabbitmq/certs/server_rmq-0_certificate.pem
COPY --chown=rabbitmq:rabbitmq --chmod=0400 ./certificates/rmq-0/server.key.pem /etc/rabbitmq/certs/server_rmq-0_key.pem

EXPOSE 4369 5671 5672 15671 15672 15692 25672 35672-35682
