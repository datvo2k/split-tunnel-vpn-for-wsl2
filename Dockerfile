# Stage 1: Build Squid from source using Debian
FROM debian:12 AS builder

# Set environment variables
ENV SQUID_VERSION 6.12


# Install necessary packages for building Squid
RUN apt-get update && \
    apt-get install -y build-essential wget tar libressl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download and extract Squid source code
RUN wget http://www.squid-cache.org/Versions/v4/squid-${SQUID_VERSION}.tar.gz && \
    tar -xzf squid-${SQUID_VERSION}.tar.gz

RUN ./configure \
        --prefix=/usr \
        --localstatedir=/var \
        --libexecdir=/usr/lib/squid \
        --datadir=/usr/share/squid \
        --sysconfdir=/etc/squid \
        --with-logdir=/var/log/squid \
        --enable-build-info="Squid proxy build by Brian Vo" \
        --enable-icmp \
        --enable-cache-digests \
        --enable-linux-netfilter \
        --disable-snmp \
        --disable-htcp \
        --disable-select \
        --disable-poll \
        --disable-kqueue \
        --disable-epoll \
        --disable-devpoll \
        --disable-auth-basic \
        --disable-ipv6 \
        --disable-zph-qos \
        --without-ldap \
        --without-xml2 \
        --with-large-files \
        --with-pidfile=/var/run/squid.pid && \
    make && \
    make install

# Stage 2: Create the final image using scratch
FROM scratch

# Copy necessary files from the builder stage
COPY --from=builder /usr /usr
COPY --from=builder /etc/squid /etc/squid
COPY --from=builder /var/log/squid /var/log/squid
COPY --from=builder /var/run/squid.pid /var/run/squid.pid

# Copy the Squid configuration file
COPY squid.conf /etc/squid/squid.conf

# Expose Squid proxy port
EXPOSE 3128

# Start Squid service
CMD ["/usr/sbin/squid", "-N", "-d", "1"]