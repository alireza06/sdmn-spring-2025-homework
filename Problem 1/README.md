## Q1. Topology Creation

![Network namespace topology with a router](figure1.png)
*Figure 1: Network namespace topology with a router*

To create the topology shown in `figure1.png`, run the `create_topo.sh` script:

```bash
cd Problem\ 1
sudo chmod +x create_topo.sh
sudo ./create_topo.sh
```

> **Note:**  
> The script clears all existing links and network namespaces before creating the new topology.

To ping nodes, use the `ns_ping.sh` script:

```bash
sudo chmod +x ns_ping.sh
sudo ./ns_ping.sh <src-ns> <dst-ns> [ping-count]
```

---

## Q2. Communication Without the "router" Namespace

![Network namespace topology without a router](figure2.png)
*Figure 2: Network namespace topology without a router*

Before proceeding, remove the `router` namespace:

```bash
sudo ip netns delete router
```

After creating the topology:

1. **Assign IP addresses** from the root namespace to the bridges (`br1`, `br2`) using the previous default gateway:
```bash
sudo ip addr add 172.0.0.1/24 dev br1
sudo ip addr add 10.10.0.1/24 dev br2
```
2. **Enable IP forwarding** in the root namespace:

    ```bash
    sudo sysctl -q -w net.ipv4.ip_forward=1
    ```

OR, to automate all the above steps, simply run the `remove_router.sh` script:
```bash
sudo ./remove_router.sh
```

Now, nodes from different subnets can communicate with each other through the root namespace, even without the `router` namespace.