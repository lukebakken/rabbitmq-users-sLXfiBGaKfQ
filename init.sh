#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

git submodule update --init

readonly all_ca_certs_file="$dir/certs/ca_certs.pem"
rm -vf "$all_ca_certs_file"

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

    if [[ -s $ca_certfile ]]
    then
        cat "$ca_certfile" >> "$all_ca_certs_file"
    else
        echo "[ERROR] expected file '$ca_certfile' to exist!" 2>&1
        exit 1
    fi
done

export DOCKER_BUILDKIT=1

docker build --pull --tag rabbitmq-users-slxfibgakfq:latest --file "$dir/docker/rmq/Dockerfile" .

docker build --pull --tag rabbitmq-users-slxfibgakfq-pika:latest --file "$dir/docker/pika/Dockerfile" .
