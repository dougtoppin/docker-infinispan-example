If you want to try out using Infinispan in a Docker container using its ReST interface here is how you can do it.
Note that the Dockerfile will disable authentication in the Infinispan default cache.
Change the container ids to your values.

For this example I am using macOS and the following Docker version. An earlier version will likely work just as well.

    $ docker version
    Client:
     Version:      1.13.0
     API version:  1.25
     Go version:   go1.7.3
     Git commit:   49bf474
     Built:        Wed Jan 18 16:20:26 2017
     OS/Arch:      darwin/amd64

    Server:
     Version:      1.13.0
     API version:  1.25 (minimum version 1.12)
     Go version:   go1.7.3
     Git commit:   49bf474
     Built:        Wed Jan 18 16:20:26 2017
     OS/Arch:      linux/amd64
     Experimental: true

Note that this will fire up a Centos-7 Linux, install Java, Infinispan, configure it a little and you are ready to go.

####Building and running
Build the container or run the one already built one in Dockerhub.
If you want to build the image yourself try this:

    docker build .

Find the container id of what you just built using the following. You should also be able to find it in the build output in `Successfully built IMAGEID`

    docker images

Now start it up and expose the ports that we need.
We will be running it as a daemon (meaning in the background).
Replace the image id at the end with your newly build id.

    docker run -d -it -p 8080:8080 -p 11222:11222 a7142852a547

Or just run the already built image in Dockerhub

    docker run -d -it -p 8080:8080 -p 11222:11222 dougtoppin/docker-infinispan-example


####Going in to the container

Go in the container and look around using the following command if you want to.
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


#####curl
The `curl` command can also be used to access the cache.

An example of a put to store the string `somethingTest2` with the key `a02` would look like this

    curl -X PUT -d 'somethingTest2' 'http://127.0.0.1:8080/rest/default/a02'

To use `curl` to get what was just stored use this

    curl -X GET 'http://127.0.0.1:8080/rest/default/a02'


####Infinispan cli

After you have done a few operations using postman go back into the shell in your container and use the `infinispan-cli` to get some stats from the cache like this:

    $ cd /opt/jboss/infinispan-server/bin
    $ sh ispn-cli.sh
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
