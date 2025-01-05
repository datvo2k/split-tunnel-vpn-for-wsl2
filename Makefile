.PHONY: up

# Run docker-compose
up:
	@if ! docker network ls | grep -q vpn_network; then \
		echo "Creating vpn_network..."; \
		docker network create vpn_network --subnet 172.30.0.0/24; \
	else \
		echo "Network vpn_network already exists"; \
	fi
	@echo "Starting containers..."
	@docker-compose -f tinyproxy.docker-compose.yml up -d

down:
	@echo "Stopping containers..."
	@docker-compose -f tinyproxy.docker-compose.yml down
	@if docker network ls | grep -q vpn_network; then \
		echo "Removing vpn_network..."; \
		docker network rm vpn_network; \
	else \
		echo "Network vpn_network does not exist"; \
	fi