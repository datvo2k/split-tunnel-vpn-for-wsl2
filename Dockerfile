FROM debian:bullseye-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Clone and build 3proxy
WORKDIR /usr/src/3proxy
RUN git clone https://github.com/3proxy/3proxy.git . && \
    ln -s Makefile.Linux Makefile && \
    make -f Makefile

# Stage 2: Runtime Image
FROM debian:bullseye-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    openresolv \
    iproute2 \
    iptables \
    wireguard-tools \
    ca-certificates \
    procps \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy 3proxy from the builder stage
COPY --from=builder /usr/src/3proxy/bin/ /usr/local/bin/

# Create necessary directories
RUN mkdir -p /etc/3proxy /var/log/3proxy && \
    chown -R nobody:nogroup /var/log/3proxy

COPY patch-wireguard.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/patch-wireguard.sh && \
    /usr/local/bin/patch-wireguard.sh

# Copy configuration files
COPY 3proxy.cfg /etc/3proxy/3proxy.cfg
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose proxy ports
EXPOSE 3128 1080

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]