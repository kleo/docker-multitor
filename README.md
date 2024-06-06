# docker-multitor

This is an Alpine Docker image that runs multitor. Multitor creates a Proxy with multiple TOR instances wich are load-balanced. For detailed information about multitor, check out https://github.com/trimstray/multitor .

# Build
git clone https://github.com/kleo/docker-multitor

cd docker-multitor

docker build -t multitor .

# Quick Start

```bash
# By default, the container runs with 5 Tor instances, HAProxy (frontend) and Privoxy (broker), which implicate the load balancer. The proxy is set up with port 16379 and the container will be removed after use.

docker run -it --rm -p 16379:16379 kleo/multitor

# Start 20 tor instances
docker run -it --rm -e "TOR_INSTANCES=20" -p 16379:16379 kleo/multitor 
```

# Advance

You can also start the container interactively

```bash
# run interactive
docker run -it --rm -p 16379:16379 kleo/multitor /bin/bash
# start multitor inside the container
multitor --init 5 --user root --socks-port 9000 --control-port 9900 --proxy privoxy --haproxy
```

For detailed information on how multitor works and what options it provides, check out the multitor wiki https://github.com/trimstray/multitor/wiki/Manual
