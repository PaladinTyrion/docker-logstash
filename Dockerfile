# logstash
FROM openjdk:8-jdk-alpine
MAINTAINER paladintyrion <paladintyrion@gmail.com>

# ensure logstash user exists
RUN addgroup -g 442 -S logstash && adduser -S -DH -s /sbin/nologin -u 442 -G logstash logstash

# install plugin dependencies
RUN apk add --no-cache \
# env: can't execute 'bash': No such file or directory
		bash \
		libc6-compat \
		libzmq

# grab su-exec for easy step-down from root
RUN apk add --no-cache 'su-exec>=0.2'

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LOGSTASH_HOME /opt/logstash
ENV LOGSTASH_PATH $LOGSTASH_HOME/bin
ENV PATH $LOGSTASH_PATH:$PATH
ENV LS_OPEN_FILES 32768

RUN mkdir -p /opt/logstash \
    && mkdir -p /var/log/logstash

ENV VERSION 6.0.0
ENV URL "https://artifacts.elastic.co/downloads/logstash"
ENV TARBALL "$URL/logstash-${VERSION}.tar.gz"
ENV TARBALL_ASC "$URL/logstash-${VERSION}.tar.gz.asc"
ENV TARBALL_SHA "0b35057a7308152de43927f06fbe0198c5c3135d9fa0dec1b48feeea084ecc04b3f6852c9c0239f6f854f5ea0a7a2cd33432a9faddbd6b523f2de336c8b21aaf  logstash.tar.gz"
ENV GPG_KEY "46095ACC8548582C1A2699A9D27D666CD88E42B4"

RUN apk update \
  && apk add --no-cache -t .build-deps wget ca-certificates gnupg openssl tar \
  && cd /tmp \
  && wget --progress=bar:force -O logstash.tar.gz "$TARBALL"; \
  if [ "$TARBALL_SHA" ]; then \
		echo "$TARBALL_SHA" | sha512sum -c -; \
	fi; \
	\
	if [ "$TARBALL_ASC" ]; then \
		wget --progress=bar:force -O logstash.tar.gz.asc "$TARBALL_ASC"; \
		export GNUPGHOME="$(mktemp -d)"; \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY"; \
		gpg --batch --verify logstash.tar.gz.asc logstash.tar.gz; \
		rm -r "$GNUPGHOME" logstash.tar.gz.asc; \
	fi; \
  \
	mkdir -p "$LOGSTASH_HOME"; \
	tar -xzf logstash.tar.gz --strip-components=1 -C "$LOGSTASH_HOME"; \
	rm -f logstash.tar.gz; \
  apk del --purge .build-deps; \
  rm -fr /tmp/* ; \
  mkdir -p /opt/logstash/pipeline

ENV LS_SETTINGS_DIR $LOGSTASH_HOME/config

RUN set -ex; \
  if [ -f "$LS_SETTINGS_DIR/log4j2.properties" ]; then \
    cp "$LS_SETTINGS_DIR/log4j2.properties" "$LS_SETTINGS_DIR/log4j2.properties.dist"; \
    truncate -s 0 "$LS_SETTINGS_DIR/log4j2.properties"; \
  fi; \
  # set up some file permissions
	for userDir in \
		"$LOGSTASH_HOME/config" \
		"$LOGSTASH_HOME/data" \
    "/var/log/logstash" \
	; do \
		if [ -d "$userDir" ]; then \
			chown -R logstash:logstash "$userDir"; \
		fi; \
	done; \
	\
	logstash --version

VOLUME ["/etc/logstash/conf.d"]

COPY config/logstash $LOGSTASH_HOME/config/
COPY config/pipeline $LOGSTASH_HOME/pipeline/
COPY logstash-entrypoint.sh /

RUN chmod +x /logstash-entrypoint.sh

EXPOSE 9600 5044

ENTRYPOINT ["/logstash-entrypoint.sh"]
CMD ["-e", ""]
