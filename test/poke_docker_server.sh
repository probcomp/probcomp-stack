#!/bin/sh

set -Ceu

image_name="probcomp/stack-${JOB_NAME}:${BUILD_NUMBER}"
cont_name="probcomp-stack-container-${JOB_NAME}-${BUILD_NUMBER}"

clean () {
    docker kill "$cont_name"
}

trap clean EXIT HUP INT TERM

docker build --no-cache -t "$image_name" -f docker/ubuntu1604-jupyter docker
docker run --rm --publish 127.0.0.1:8082:8080/tcp \
    -v docker:/notebook \
    --name "$cont_name" \
    "$image_name" &

sleep 5

rm -f body header header-1
curl -L --dump-header header http://localhost:8082/ > body
grep HTTP header | tr -d '\r' > header-1
diff -u - header-1 <<EOF
HTTP/1.1 302 Found
HTTP/1.1 200 OK
EOF
