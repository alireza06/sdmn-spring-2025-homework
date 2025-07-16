# Simple Bash Container Runtime

This project provides a minimal container runtime written in Bash. It demonstrates how to use Linux namespaces and cgroups to create an isolated environment similar to a lightweight container.

## Features

- Isolates processes using PID, UTS, network, and mount namespaces
- Sets a custom hostname for the container
- Optionally applies a memory limit using cgroups
- Uses a copy of a base Ubuntu root filesystem as the container's root
- Cleans up resources automatically on exit

## Requirements

- Linux system with support for namespaces and cgroups
- Root privileges (`sudo`)
- A base root filesystem (e.g., Ubuntu) at `/var/lib/mycontainers/ubuntu2004/`
- Bash, `unshare`, and standard core utilities

## Usage

```bash
sudo ./mybuild.sh <hostname> [memory_limit_in_mb]
```

- `<hostname>`: The desired hostname for the container.
- `[memory_limit_in_mb]`: (Optional) Memory limit for the container in megabytes.

### Example

```bash
sudo ./mybuild.sh testcontainer 128
```

This will create a container named `testcontainer` with a 128 MB memory limit.

## How It Works

1. Copies the base root filesystem to a temporary location.
2. Sets up a cgroup for memory limiting (if specified).
3. Uses `unshare` to launch a new shell in isolated namespaces.
4. Sets the container's hostname.
5. Changes the root filesystem to the container's private copy.
6. Cleans up all resources when the container exits.

## Notes

- The script must be run as root.
- The container runs an interactive shell. If you want to keep it alive non-interactively, modify the last command to use `sleep infinity`
- Make sure the base root filesystem exists and is properly set up.