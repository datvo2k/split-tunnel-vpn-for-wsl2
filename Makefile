export GO ?= go
export CGO_ENABLED = 0

TAG := $(shell git describe --always --tags $(git rev-list --tags --max-count=1) --match v*)

.PHONY: all
all: wireproxy

.PHONY: wireproxy
wireproxy:
	${GO} build -trimpath -ldflags "-s -w -X 'main.version=${TAG}'" ./cmd/wireproxy

.PHONY: clean
clean:
	${RM} wireproxy

.PHONY: dockerrun
dockerrun:
	docker build -t wireproxy .
	docker network inspect wireguard >/dev/null 2>&1 || docker network create --subnet=172.20.0.0/16 wireguard
	docker run -d -p 127.0.0.1:25345:25345 --name wireproxy --net wireguard --ip 172.20.0.2 -v /home/datvo/wiregruard/cl-san.conf:/etc/wireproxy/config/cl-san.conf wireproxy --config /etc/wireproxy/config/cl-san.conf
.PHONY: dockerclean
dockerclean:
	docker stop wireproxy || true
	docker rm wireproxy || true
	docker rmi wireproxy