# My Status Server

This Problem provides a simple Python HTTP server that handles a single endpoint: `/api/v1/status`. The server responds to `GET` and `POST` requests, maintaining an in-memory status value that can be updated via `POST` and retrieved via `GET`.

## Prerequisites

- Docker installed on your system (version 20.10 or later recommended)
- Basic knowledge of Docker commands

## Folder Contents

- `python_http_server.py` – Python HTTP server script
- `Dockerfile` – Docker configuration to build and run the server

## Building the Docker Image

1. Open a terminal and navigate to the project directory

2. Build the Docker image with the following command:
   ```bash
   docker build -t my-status-server .
   ```
   This command creates a Docker image named `my-status-server` based on `ubuntu:20.04`, installs Python, copies the server python script, and sets up the startup command.

## Running the Container

Run the container in interactive mode, mapping port 8000 on the host to port 8000 in the container:

```bash
docker run -p 8000:8000 -it --rm my-status-server
```

- `-it` runs the container interactively.
- `--rm` automatically removes the container when it exits.
- You can stop the server at any time by pressing `Ctrl+C`.

## Testing the Server

You can test the endpoints using `curl` or any HTTP client:

### GET Request

Initially, the status defaults to `OK`.

```bash
curl http://localhost:8000/api/v1/status
# Response:
# { "status": "OK" }
```

### POST Request

Update the status by sending a JSON body. The server responds with status code `201` and the new value.

```bash
curl -X POST \
     -H "Content-Type: application/json" \
     -d '{"status": "not OK"}' \
     http://localhost:8000/api/v1/status
# Response:
# { "status": "not OK" }
```

Subsequent `GET` requests will now return the updated status:

```bash
curl http://localhost:8000/api/v1/status
# Response:
# { "status": "not OK" }
```

## Cleaning Up the Image

If you no longer need the Docker image, remove it with:

```bash
docker rmi my-status-server
```

---