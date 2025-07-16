#!/bin/bash
# A simple container runtime in Bash, demonstrating the use of Linux namespaces
# and cgroups to create an isolated environment.

# --- Configuration ---S
# The path to the base Ubuntu root filesystem.
# The script will create a copy of this for each container.
BASE_ROOTFS="/var/lib/mycontainers/ubuntu2004/"
# BASE_ROOTFS="/"
CGROUP_BASE="/sys/fs/cgroup"

# --- Function to display usage ---
usage() {
    echo "Usage: $0 <hostname> [memory_limit_in_mb]"
    echo "This script must be run as root (e.g., with sudo)."
    exit 1
}

# --- Cleanup function ---
# This function is called on script exit to clean up container resources.
cleanup() {
    echo "--- Cleaning up container resources for $HOSTNAME ---"
    # Unmount the proc filesystem inside the container's rootfs
    # Redirect errors to /dev/null in case it's already unmounted
    umount "$CONTAINER_ROOTFS/proc" &>/dev/null

    # Remove the container's temporary root filesystem
    if [ -d "$CONTAINER_ROOTFS" ]; then
        echo "Removing container root filesystem at $CONTAINER_ROOTFS ..."
        rm -rf "$CONTAINER_ROOTFS"
    fi

    # Remove the cgroup directory.
    if [ -n "$MEMORY_LIMIT_MB" ] && [ -d "$CGROUP_PATH" ]; then
        echo "Removing cgroup directory at $CGROUP_PATH ..."
        rmdir "$CGROUP_PATH" &>/dev/null
    fi
    echo "Cleanup complete."
}


# --- Main Script Logic ---

# 1. Check for root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo." >&2
    exit 1 
fi

# 2. Check command-line arguments
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    usage
fi

# 3. Parse command-line arguments
HOSTNAME=$1
MEMORY_LIMIT_MB=${2:-}

# 4. Verify that the base root filesystem exists
if [ ! -d "$BASE_ROOTFS" ]; then
    echo "Error: Base root filesystem not found at $BASE_ROOTFS" >&2
    exit 1
fi

# --- Prepare container-specific assets ---

# Create a unique rootfs for this container instance by copying the base.
CONTAINER_ROOTFS="/tmp/container_$$" # Use PID for uniqueness
echo "Creating container root filesystem at $CONTAINER_ROOTFS ..."
# Use cp instead of shutil.copytree for a shell equivalent
cp -r "$BASE_ROOTFS" "$CONTAINER_ROOTFS"

# Prepare cgroup directory if a memory limit is set
if [ -n "$MEMORY_LIMIT_MB" ]; then
    CGROUP_PATH="$CGROUP_BASE/$HOSTNAME"
    if [ ! -d "$CGROUP_BASE" ]; then
        echo "Error: Cgroup controller not found at $CGROUP_BASE" >&2
        rm -rf "$CONTAINER_ROOTFS" # Clean up partial setup
        exit 1
    fi

    # Create the cgroup directory for the container
    mkdir -p "$CGROUP_PATH"

    # Set the memory limit
    MEMORY_IN_BYTES=$((MEMORY_LIMIT_MB * 1024 * 1024))
    echo "Setting memory limit to $MEMORY_LIMIT_MB MB ..."
    echo "$MEMORY_IN_BYTES" > "$CGROUP_PATH/memory.max"
else
    echo "No memory limit set for container '$HOSTNAME'."
fi

# --- Set up cleanup trap ---
# The 'trap' command ensures the cleanup function is called when the script exits,
# for any reason (normal exit, Ctrl+C, etc.).
trap cleanup EXIT

# --- Create the container ---
# The 'unshare' command is the heart of the operation. It runs a program
# (in this case, a new shell) in new namespaces.
#
# --fork: Forks a new process before unsharing, making it the child. The parent script waits.
# --pid: Creates a new PID namespace.
# --mount-proc: Mounts a new /proc filesystem after creating the PID namespace.
# --uts: Creates a new UTS namespace for setting a custom hostname.
# --net: Creates a new network namespace.
# --mount: Creates a new mount namespace.
#
# The command executed inside the new namespaces is a sub-shell that performs
# the container setup.

echo "Launching container '$HOSTNAME'..."
if [ -n "$MEMORY_LIMIT_MB" ]; then
    echo "Container will have a memory limit of $MEMORY_LIMIT_MB MB."
fi

unshare --fork --pid --mount-proc --uts --net --mount /bin/bash -c "
    # This part of the script runs INSIDE the new namespaces as the child process.

    # Add the current process (the container's init) to the cgroup
    # The '$$' here refers to the PID of *this* sub-shell (where it is '1').
    if [ -n \"$MEMORY_LIMIT_MB\" ]; then
        echo \$$ > \"$CGROUP_PATH/cgroup.procs\"
    fi

    # 1. Set the container's hostname
    hostname \"$HOSTNAME\"

    # # 2. Isolate the filesystem with chroot
    # # Change the root directory to our container's private rootfs.
    # # Bind mount the Host container's (for accessing /dev/null and /dev/zeros for memory limit testing)
    # mount --bind /dev \"$CONTAINER_ROOTFS/dev\"  
    # chroot \"$CONTAINER_ROOTFS\" /bin/bash

    # 2. Isolate the filesystem with pivot_root
    mkdir -p \"$CONTAINER_ROOTFS/old_root\"
    mount --bind \"$CONTAINER_ROOTFS\" \"$CONTAINER_ROOTFS\" 
    cd $CONTAINER_ROOTFS
    pivot_root . ./old_root
    mount -t proc proc /proc
    umount -l ./old_root
    rmdir ./old_root
    /bin/bash
"