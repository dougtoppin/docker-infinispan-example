FROM jboss/infinispan-server:7.1.0.Final
LABEL maintainer "dougtoppin@gmail.com"
LABEL org.label-schema.vcs-url="https://github.com/dougtoppin/docker-infinispan-example"
LABEL org.label-schema.description="Infinispan cache ReST example using Postman and Newman"

# Turn off Infinispan authentication for the default cache by removing the
# authentication portion of it.
# Note that there is a configuration difference between Infinispan 7.* and 8.
# This example is using Infinispan 7.1.

# the original line probably looks like this:
# <rest-connector virtual-server="default-host" cache-container="local" security-domain="other" auth-method="BASIC"/>

# we are going to remove this from that line: cache-container="local" security-domain="other" auth-method="BASIC"
RUN sed -i 's/.*rest-connector.*/<rest-connector virtual-server=\"default-host\" cache-container=\"local\"\/>/' /opt/jboss/infinispan-server/standalone/configuration/standalone.xml

# Expose Infinispan server  ports
EXPOSE 8080 8181 9990 11211 11222

# Run Infinispan server and bind to just the local interface
CMD ["/opt/jboss/infinispan-server/bin/standalone.sh", "-b", "127.0.0.1"]

