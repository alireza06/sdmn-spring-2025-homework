echo "Removing router namespace ..."
ip netns delete router

echo "Adding bridge addresses ..."
ip addr add 172.0.0.1/24 dev br1
ip addr add 10.10.0.1/24 dev br2