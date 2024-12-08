FROM linuxserver/wireguard:latest

RUN apk update
RUN apk add tinyproxy
RUN apk add coreutils

COPY ./config/start-tinyproxy.sh /start-tinyproxy.sh
RUN chmod +x /start-tinyproxy.sh
EXPOSE 8888
ENTRYPOINT [ "/start-tinyproxy.sh" ]