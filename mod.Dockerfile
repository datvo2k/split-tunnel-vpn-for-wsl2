FROM docker.io/golang:1.23 as build

WORKDIR /usr/src/wireproxy
COPY . .

RUN make

FROM gcr.io/distroless/static-debian11:nonroot
COPY --from=build /usr/src/wireproxy/wireproxy /usr/bin/wireproxy

VOLUME [ "/etc/wireproxy"]
ENTRYPOINT [ "/usr/bin/wireproxy" ]
CMD [ "--config", "/etc/wireproxy/config" ]

LABEL org.opencontainers.image.title="wireproxy"
LABEL org.opencontainers.image.description="Wireguard client that exposes itself as a socks5 proxy"