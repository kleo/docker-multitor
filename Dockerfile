FROM alpine:3.20

ENV BUILD_PACKAGES="build-base openssl" \
    PACKAGES="tor sudo bash git haproxy privoxy npm procps"

# install requirements
RUN \
  apk update && apk add --no-cache $BUILD_PACKAGES $PACKAGES && \
  npm install -g http-proxy-to-socks

# fix certificate problem (avoid con reset by peer)
RUN \
  apk add ca-certificates wget && \
  update-ca-certificates

# install polipo
# RUN \
# 	wget https://github.com/jech/polipo/archive/master.zip -O polipo.zip && \
# 	unzip polipo.zip && \
#   cd polipo-master && \
#   make && \
#   install polipo /usr/local/bin/ && \
#   cd .. && \
#   rm -rf polipo.zip polipo-master && \
#   mkdir -p /usr/share/polipo/www /var/cache/polipo 

# clean build packages
RUN \
  apk del $BUILD_PACKAGES

# rename privoxy .new files
# privoxy .new suffix added on alpine:3.12 privoxy (3.0.33-r0) and later.
# causes multitor to not properly start
# for package contents see https://pkgs.alpinelinux.org/contents?branch=v3.12&name=privoxy&arch=x86_64&repo=main
RUN mv /etc/privoxy/config.new /etc/privoxy/config && \
    mv /etc/privoxy/default.action.new /etc/privoxy/default.action && \
    mv /etc/privoxy/default.filter.new /etc/privoxy/default.filter && \
    mv /etc/privoxy/match-all.action.new /etc/privoxy/match-all.action && \
    mv /etc/privoxy/regression-tests.action.new /etc/privoxy/regression-tests.action.new && \
    mv /etc/privoxy/trust.new /etc/privoxy/trust && \
    mv /etc/privoxy/user.action.new /etc/privoxy/user.action && \
    mv /etc/privoxy/user.filter.new /etc/privoxy/user.filter

# install multitor
RUN	git clone https://github.com/kleo/multitor && \
	cd multitor && \
	./setup.sh install && \
# create log folders
  mkdir -p /var/log/multitor/privoxy/ && \
  mkdir -p /var/log/polipo/ && \
# let haproxy listen from outside, instand only in the docker container
  sed -i s/127.0.0.1:16379/0.0.0.0:16379/g templates/haproxy-template.cfg

COPY startup.sh /multitor/
RUN chmod +x /multitor/startup.sh

WORKDIR /multitor/
EXPOSE	16379

#CMD multitor --init 5 --user root --socks-port 9000 --control-port 9900 --proxy privoxy --haproxy --verbose --debug > /tmp/multitor.log; tail -f /tmp/multitor.log
CMD ["./startup.sh"]