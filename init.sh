#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

git submodule update --init

for ((i = 0; i < 2; i++))
do
    ca_certfile="$dir/certs/rmq-$i/ca_certificate.pem"
    if [[ -s $ca_certfile ]]
    then
        echo "[INFO] file '$ca_certfile' already exists, not regenerating!"
    else
        make -C "$dir/tls-gen/basic" "CN=rmq-$i"
        cp -v "$dir/tls-gen/basic/result/"*.pem "$dir/certs/rmq-$i"
    fi
done

# docker build --tag rabbitmq-users-slxfibgakfq:latest --file "$dir/docker/rmq/Dockerfile" .

docker build --tag rabbitmq-users-slxfibgakfq-pika:latest --file "$dir/docker/pika/Dockerfile" .

## {
##     cd "$dir/rabbitmq-server" && asdf local erlang 24.3.4 && asdf local elixir 1.12.3-otp-24
##     make FULL=1
## } &
## 
## make -C "$dir/rabbitmq-perf-test" compile &
## 
## wait
## 
## make -C "$dir/rabbitmq-server" RABBITMQ_CONFIG_FILE="$dir/rabbitmq.conf" PLUGINS='rabbitmq_management rabbitmq_top' NODES=3 start-cluster
## 
## (cd "$dir/rabbitmq-server" && ./sbin/rabbitmqctl --node rabbit-1 set_policy --apply-to queues \
##     --priority 0 policy-0 ".*" '{"ha-mode":"all", "ha-sync-mode": "automatic", "queue-mode": "lazy"}')
## 
## (cd "$dir/rabbitmq-server" && ./sbin/rabbitmqctl --node rabbit-1 set_policy --apply-to queues \
##     --priority 1 policy-1 ".*" '{"ha-mode":"all", "ha-sync-mode": "automatic"}')
## 
## make -C "$dir/rabbitmq-perf-test" ARGS='--consumers 0 --producers 1 --predeclared --queue gh-5086 --pmessages 1500000 --size 1024' run
## 
## (cd "$dir/rabbitmq-server" && ./sbin/rabbitmqctl --node rabbit-1 clear_policy policy-1)
