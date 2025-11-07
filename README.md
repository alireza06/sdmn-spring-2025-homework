# SDN Spring 2025 Homework

This repository contains solutions for Software Defined Networking (SDN) homework, Spring 2025. The project is organized into three main directories, each addressing a different problem:

## Directory Structure

- **Problem 1:** Network Namespace Topology & Scripts
- **Problem 2:** Minimal Bash Container Runtime
- **Problem 3:** Simple Python HTTP Server API

---

## Problem 1: Network Namespace Topology

This directory contains scripts and documentation for creating and managing network namespaces, bridges, and routers using Linux networking tools.

- **Scripts:**  
  - `create_topo.sh`: Sets up the network topology with namespaces, bridges, and a router.
  - `remove_router.sh`: Removes the router namespace and configures bridges for direct communication.
  - `ns_ping.sh`: Utility to ping between namespaces.

- **Documentation:**  
  - `README.md`: Step-by-step instructions and explanations.
  - Topology diagrams (`figure1.png`, `figure2.png`, etc.)

---

## Problem 2: Minimal Bash Container Runtime

This directory demonstrates how to build a simple container runtime using Bash, Linux namespaces, and cgroups.

- **Script:**  
  - `mybuild.sh`: Creates an isolated container environment with custom hostname, root filesystem, and optional memory limits.

- **Features:**  
  - PID, UTS, NET, and MOUNT namespace isolation
  - Custom root filesystem
  - Optional cgroup-based memory limiting
  - Automatic cleanup

- **Documentation:**  
  - `README.md`: Usage instructions and technical overview.

---

## Problem 3: Simple Python HTTP Server API

This directory contains a minimal Python HTTP server implementing a RESTful API for status management.

- **Script:**  
  - `python_http_server.py`: HTTP server with GET/POST endpoints for status.

- **Features:**  
  - `/api/v1/status` endpoint for getting and setting status via JSON
  - Simple, stateless design

- **Documentation:**  
  - `README.md`: API usage and example requests.

---

## Getting Started

1. Clone the repository:
    ```bash
    git clone https://github.com/alireza06/sdmn-spring-2025-homework
    cd SDN_hw2
    ```

2. See each problem's directory for specific instructions and requirements.

---