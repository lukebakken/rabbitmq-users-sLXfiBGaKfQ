FROM rabbitmq:3-management

COPY --chown=rabbitmq:rabbitmq --chmod=0400 ./docker/rmq/erlang.cookie /var/lib/rabbitmq/.erlang.cookie
COPY --chown=rabbitmq:rabbitmq ./docker/rmq/enabled_plugins /etc/rabbitmq/
COPY --chown=rabbitmq:rabbitmq ./docker/rmq/rabbitmq.conf /etc/rabbitmq/rabbitmq.conf
COPY --chown=rabbitmq:rabbitmq ./docker/rmq/definitions.json /etc/rabbitmq/

RUN mkdir -p /etc/rabbitmq/certs && chown rabbitmq:rabbitmq /etc/rabbitmq/certs
RUN mkdir -p /etc/rabbitmq/trust_store && chown rabbitmq:rabbitmq /etc/rabbitmq/trust_store

# Test if we can use client certificate to whitelist directly
# COPY --chown=rabbitmq:rabbitmq --chmod=0400 ./certificates/client/cert.pem /etc/rabbitmq/trust_store/client_rmq_certificate.pem

# Now uses the intermediate_ca_server CA certificate
COPY --chown=rabbitmq:rabbitmq --chmod=0400 ./certificates/intermediate_ca_server/certs/ca-chain-server.pem /etc/rabbitmq/certs/ca.pem
COPY --chown=rabbitmq:rabbitmq --chmod=0400 ./certificates/server/cert.pem /etc/rabbitmq/certs
COPY --chown=rabbitmq:rabbitmq --chmod=0400 ./certificates/server/key.pem /etc/rabbitmq/certs


EXPOSE 4369 5671 5672 15671 15672 15692 25672 35672-35682
