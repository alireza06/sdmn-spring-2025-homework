echo "-----------------------------"
echo "=== Pinging between namespaces ==="
echo "$# arguments provided: $@"

if [ $# -lt 2 ] || [ $# -gt 3 ]; then
  echo "Usage: $0 <src-ns> <dst-ns> [ping-count]"
  exit 1
fi

SRC=$1
DST=$2
COUNT=${3:--1}  # Default to -1 if not provided

# Use a case statement to map the SRC to the correct interface
if [ "$DST" = "router" ]; then
  VETH_INTERFACE="" 
  case "$SRC" in
    "node1" | "node2")
        VETH_INTERFACE="veth0" # veth0-router for br1 (node1 and node2)
        ;;
    "node3" | "node4")
        VETH_INTERFACE="veth1" # veth1-router for br2 (node3 and node4)
        ;;
    *) # This is a "catch-all" for any other value
        echo "Error: Unknown or unsupported node name '$SRC'." >&2
        exit 1
        ;;
    esac
    DST_IP=$(ip netns exec "$DST" ip -o -4 addr show | grep "$VETH_INTERFACE" | awk '{print $4}' | sed 's/\/.*//g')
else
    DST_IP=$(ip netns exec "$DST" ip -o -4 addr show | grep "$DST" | awk '{print $4}' | sed 's/\/.*//g' | tail -n 1)
fi

echo "Destination IP for $DST is $DST_IP"

echo "Pinging $DST_IP from $SRC..."
if [ $COUNT -lt 1 ]; then
  echo "Pingging indefinitely (default behavior):"
  ip netns exec "$SRC" ping "$DST_IP"
else
  ip netns exec "$SRC" ping "$DST_IP" -c "$COUNT"
fi