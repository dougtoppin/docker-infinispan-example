#!/bin/sh

# start up the cache server in the background so that we can continue to the next step
docker-compose up -d infinispan

# execute the tests in the postman collection
docker-compose up test

# tell the cache to shutdown
docker-compose exec infinispan sh /opt/jboss/infinispan-server/bin/ispn-cli.sh -c command="shutdown"

# play it safe by making sure that we do not leave anything running
docker-compose down

