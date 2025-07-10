echo "Cleaning up..."
echo "=== Deleting namespaces ==="
ip netns | awk '{print $1}' | xargs -r -n1 ip netns delete
echo "=== Deleting bridges and interfaces ==="
ip link show | grep -E 'br[12]|veth-' | awk '{print $2}' | sed 's/[:@].*//g' | xargs -r -n1 ip link delete
echo "-----------------------------"

echo "=== Creating namespaces and set \"lo\" links up ==="
for ns in node1 node2 node3 node4 router; do
  ip netns add "$ns"
  ip netns exec "$ns" ip link set lo up
done

echo "=== Creating bridges and set them up ==="
for br in br1 br2; do
  ip link add name "$br" type bridge
  ip link set "$br" up
done

echo "=== Attaching namespaces to bridges nd set all links up ==="
# node1 & node2 on 172.0.0.0/24 (br1)
for ns in node1 node2; do
# pick the right IP suffix
  if [ "$ns" = "node1" ]; then
    suffix=2
  else
    suffix=3
  fi
  ip link add veth-${ns} type veth peer name veth-${ns}-br
  ip link set veth-${ns} netns "$ns"
  ip netns exec "$ns" ip addr add 172.0.0."$suffix"/24 dev veth-${ns}
  ip netns exec "$ns" ip link set veth-${ns} up
  ip link set veth-${ns}-br master br1
  ip link set veth-${ns}-br up
done
# node3 & node4 on 10.10.0.0/24 (br2)
for ns in node3 node4; do
# pick the right IP suffix
  if [ "$ns" = "node3" ]; then
    suffix=2
  else
    suffix=3
  fi
  ip link add veth-${ns} type veth peer name veth-${ns}-br
  ip link set veth-${ns} netns "$ns"
  ip netns exec "$ns" ip addr add 10.10.0."$suffix"/24 dev veth-${ns}
  ip netns exec "$ns" ip link set veth-${ns} up
  ip link set veth-${ns}-br master br2
  ip link set veth-${ns}-br up
done

echo "=== Creating router interfaces and set them up ==="
# router on
ip link add veth0-router type veth peer name veth-router-br1
ip link add veth1-router type veth peer name veth-router-br2
ip link set veth0-router netns router
ip link set veth1-router netns router
ip netns exec router ip addr add 172.0.0.1/24 dev veth0-router
ip netns exec router ip addr add 10.10.0.1/24 dev veth1-router
ip netns exec router ip link set veth0-router up
ip netns exec router ip link set veth1-router up
ip link set veth-router-br1 master br1
ip link set veth-router-br2 master br2
ip link set veth-router-br1 up
ip link set veth-router-br2 up

for ns in node1 node2; do
  echo "=== Setting up routing for $ns ==="
  ip netns exec "$ns" ip route add default via 172.0.0.1
done

for ns in node3 node4; do
  echo "=== Setting up routing for $ns ==="
  ip netns exec "$ns" ip route add default via 10.10.0.1
done

echo "=== Configuring routing ==="
# Enable forwarding in router namespace
ip netns exec router sysctl -q -w net.ipv4.ip_forward=1