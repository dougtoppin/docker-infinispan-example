#!/bin/sh

docker-compose up -d infinispan
sleep 5
docker-compose up test
docker-compose down

