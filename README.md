If you want to try out using Infinispan in a Docker container using its ReST interface here is how you can do it. This example also demonstrates the use of both the Postman and Newman test tools as Docker containers.
Note that the Dockerfile will disable authentication in the Infinispan default cache.
Change the container ids to your values where necessary. If you use the pre-built images on dockerhub it will be more convenient.

For this example I am using macOS and the following Docker versions. An earlier version may work just as well.

    $ docker version
    Client:
     Version:      17.03.0-ce
     API version:  1.26
     Go version:   go1.7.5
     Git commit:   60ccb22
     Built:        Thu Feb 23 10:40:59 2017
     OS/Arch:      darwin/amd64

    Server:
     Version:      17.03.0-ce
     API version:  1.26 (minimum version 1.12)
     Go version:   go1.7.5
     Git commit:   3a232c8
     Built:        Tue Feb 28 07:52:04 2017
     OS/Arch:      linux/amd64
     Experimental: true

     $ docker-compose version
     docker-compose version 1.11.2, build dfed245
     docker-py version: 2.1.0
     CPython version: 2.7.12
     OpenSSL version: OpenSSL 1.0.2j  26 Sep 2016

Note that this will fire up a Centos-7 Linux, install Java, Infinispan, configure it a little and you are ready to go.

####Building and running
Build the container or run the one already built one in Dockerhub.
If you want to build the image yourself try this:

    docker build -t docker-infinispan .

Now start it up and expose the ports that we need.
We will be running it as a daemon (meaning in the background).
Replace the image id at the end with your newly build id.

    docker run -d -it -p 8080:8080 -p 11222:11222 docker-infinispan

Or just run the already built image in Dockerhub

    docker run -d -it -p 8080:8080 -p 11222:11222 dougtoppin/docker-infinispan-example


####Going in to the container

Go in the container with a shell and look around using the following command if you want to.
The `standalone.xml` that was modified to remove authentication can be found at `/opt/jboss/infinispan-server/standalone/configuration/standalone.xml`.
Note that `$(docker ps -lq)` will return the container id of the most recently run container.

    docker exec -i -t $(docker ps -lq) /bin/bash

####Testing
Once your container is running you can use the ReST interface to access the Infinispan server.
This can be done using either a tool such as `Postman` or `curl`


#####Postman
The `postman` collection file in this directory contains an example of how to `put` something in to the default cache and then `get` it out again.
Just import it into your postman client and try it out.
Use the `put` entry first and then using `get` should return the same value.

The uri for the put ends with the key that will be used for what is being stored.
In this case it should be `a02`.
The string `something` in the payload is what will be stored in the cache.

The `get` request ends in the key for the value to be retrieved.
Send it and the response should contain `something` with a status of `200 OK`.

Try changing the key `a02` to something else and the request should not return anything (note the `404 Not Found` status if you do).

#####Newman
Newman is a tool that allows you to run Postman collections at the shell. This facilitates automated testing such as in continuous integration. Newman can also be run as a container as follows. In this example, the current directory (containing the Postman collection) is passed to the container in the directory that it expects to find files (/etc/newman).
Also note the network argument of host. This tells Docker to give the contain access to the host network rather than using it's own network space.

    docker run -v $(pwd):/etc/newman --network=host -t postman/newman_ubuntu1404  run InfinispanDockerExample.json.postman_collection

The output of the run will note the tests that were run and the results which should indicate that 2 tests were performed (put and get) and the correct status (http response code 200) and expected get results were returned.

    newman

    Infinispan docker example

    ❏ requests
    ↳ put example
      PUT http://127.0.0.1:8080/rest/default/a02 [200 OK, 144B, 22ms]
      ✓  Status code is 200

    ↳ get example
      GET http://127.0.0.1:8080/rest/default/a02 [200 OK, 255B, 10ms]
      ✓  Status code is 200
      ✓  Body is correct

    ┌─────────────────────────┬──────────┬──────────┐
    │                         │ executed │   failed │
    ├─────────────────────────┼──────────┼──────────┤
    │              iterations │        1 │        0 │
    ├─────────────────────────┼──────────┼──────────┤
    │                requests │        2 │        0 │
    ├─────────────────────────┼──────────┼──────────┤
    │            test-scripts │        2 │        0 │
    ├─────────────────────────┼──────────┼──────────┤
    │      prerequest-scripts │        0 │        0 │
    ├─────────────────────────┼──────────┼──────────┤
    │              assertions │        3 │        0 │
    ├─────────────────────────┴──────────┴──────────┤
    │ total run duration: 140ms                     │
    ├───────────────────────────────────────────────┤
    │ total data received: 9B (approx)              │
    ├───────────────────────────────────────────────┤
    │ average response time: 16ms                   │
    └───────────────────────────────────────────────┘


#####curl
The `curl` command can also be used to access the cache.

An example of a put to store the string `somethingTest2` with the key `a02` would look like this

    curl -X PUT -d 'somethingTest2' 'http://127.0.0.1:8080/rest/default/a02'

To use `curl` to get what was just stored use this

    curl -X GET 'http://127.0.0.1:8080/rest/default/a02'


####Infinispan cli

After you have done a few operations using postman try using the `infinispan-cli` to get some stats from the cache like this:

    $ docker exec -it $(docker ps -lq) sh /opt/jboss/infinispan-server/bin/ispn-cli.sh

    You are disconnected at the moment. Type 'connect' to connect to the server or 'help' for the list of supported commands.
    [disconnected /]
    connect
    [standalone@localhost:9990 /] cd /subsystem=infinispan/cache-container=local/
    [standalone@localhost:9990 cache-container=local] stats default

You should see some output containing Infinispan metrics that should look similar to the following. Note the `numberOfEntries` field which should be the number of entries you have stored in the cache.

    Statistics: {
    evictions: 0
    averageRemoveTime: 0
    removeHits: 0
    stores: 1
    averageReadTime: 0
    timeSinceReset: 1291
    hits: 1
    readWriteRatio: 2.0
    statisticsEnabled: true
    elapsedTime: 1291
    misses: 1
    numberOfEntries: 1
    averageWriteTime: 4
    removeMisses: 0
    hitRatio: 0.5
    }
    LockManager: {
      concurrencyLevel: 1000
      numberOfLocksAvailable: 0
      numberOfLocksHeld: 0
    }


There are a bunch of other functions and commands that you can do so give them a try if you feel like it.  
When you are all done looking around in Infinispan cli exit like this

    [standalone@localhost:9990 /] quit

When you are all done with your container shell exit it as well

    exit

Now stop the container with (using the same container id from the `exec` command)

    docker stop b8c20c0bafe9

#####docker-compose
docker-compose is an orchestration mechanism that allows grouping related services into a single docker-compose.yml file.
Using that enables starting all of the related services using a single `docker-compose up` command.
Compose can also facilitate automated regression testing by starting the necessary services, running regression testing and then stopping all of the services.

First ensure that any containers run using the previous instructions have been stopped (to prevent port conflicts).
Next, the `regrtest-compose.sh` script will start the Infinispan service as a daemon, then run the Postman collection using the Newman cli and finally stopping the Infinispan service.

    $ ./regrtest-compose.sh
    Creating network "dockerinfinispanexample_default" with the default driver
    Creating infinispan
    infinispan is up-to-date
    Creating dockerinfinispanexample_test_1
    Attaching to dockerinfinispanexample_test_1
    test_1        | newman
    test_1        |
    test_1        | Infinispan docker example
    test_1        |
    test_1        | ❏ requests
    test_1        | ↳ put example
    test_1        |   PUT http://infinispan:8080/rest/default/a02 [200 OK, 144B, 171ms]
    test_1        |   ✓  Status code is 200
    test_1        |
    test_1        | ↳ get example
    test_1        |   GET http://infinispan:8080/rest/default/a02 [200 OK, 255B, 13ms]
    test_1        |   ✓  Status code is 200
    test_1        |   ✓  Body is correct
    test_1        |
    test_1        | ┌─────────────────────────┬──────────┬──────────┐
    test_1        | │                         │ executed │   failed │
    test_1        | ├─────────────────────────┼──────────┼──────────┤
    test_1        | │              iterations │        1 │        0 │
    test_1        | ├─────────────────────────┼──────────┼──────────┤
    test_1        | │                requests │        2 │        0 │
    test_1        | ├─────────────────────────┼──────────┼──────────┤
    test_1        | │            test-scripts │        2 │        0 │
    test_1        | ├─────────────────────────┼──────────┼──────────┤
    test_1        | │      prerequest-scripts │        0 │        0 │
    test_1        | ├─────────────────────────┼──────────┼──────────┤
    test_1        | │              assertions │        3 │        0 │
    test_1        | ├─────────────────────────┴──────────┴──────────┤
    test_1        | │ total run duration: 273ms                     │
    test_1        | ├───────────────────────────────────────────────┤
    test_1        | │ total data received: 9B (approx)              │
    test_1        | ├───────────────────────────────────────────────┤
    test_1        | │ average response time: 92ms                   │
    test_1        | └───────────────────────────────────────────────┘
    dockerinfinispanexample_test_1 exited with code 0
    Stopping infinispan ... done
    Removing dockerinfinispanexample_test_1 ... done
    Removing infinispan ... done
    Removing network dockerinfinispanexample_default
