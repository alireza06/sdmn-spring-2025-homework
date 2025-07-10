echo "-----------------------------"
echo "=== Pinging between namespaces ==="
echo "$# arguments provided: $@"

if [ $# -lt 2 ] || [ $# -gt 3 ]; then
  echo "Usage: $0 <src-ns> <dst-ns-ip> [ping-count]"
  exit 1
fi

SRC=$1
DST_IP=$2
COUNT=${3:--1}  # Default to -1 if not provided

echo "Pinging $DST_IP from $SRC..."
if [ $COUNT -eq -1 ]; then
  echo "Pingging indefinitely (default behavior):"
  ip netns exec "$SRC" ping "$DST_IP"
else
  ip netns exec "$SRC" ping "$DST_IP" -c "$COUNT"
fi