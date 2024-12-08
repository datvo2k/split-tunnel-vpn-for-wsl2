# VPN Setup Guide

This guide will help you set up a VPN using Docker and Tinyproxy.

## Prerequisites

- Docker installed on your system
- Docker Compose installed on your system

## Steps

1. Create a Docker network with a specific subnet:

    ```sh
    docker network create --subnet 172.30.0.0/24 vpn_network
    ```

2. Run the Tinyproxy container using Docker Compose:

    ```sh
    docker-compose -f tinyproxy.docker-compose.yml up -d
    ```

## Notes

- Ensure that the `tinyproxy.docker-compose.yml` file is correctly configured for your needs.
- The `vpn_network` subnet can be adjusted if needed, but make sure it does not conflict with existing networks.

## Check connect
`curl -x "http://127.0.0.1:8888" "https://ifconfig.me/"`

## Troubleshooting

- If you encounter any issues, check the Docker logs for more information:

    ```sh
    docker-compose logs
    ```

- Verify that the Docker network was created successfully:

    ```sh
    docker network ls
    ```

- Check the status of the Tinyproxy container:

    ```sh
    docker ps
    ```

For more information, refer to the Docker and Tinyproxy documentation.
