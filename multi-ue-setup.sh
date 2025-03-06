#!/bin/bash

# Define the target directory
TARGET_DIR="cmake_targets/ran_build/build"
TARGET_SCRIPT="$TARGET_DIR/multi-ue"

# Ensure the target directory exists
mkdir -p "$TARGET_DIR"

# Create the multi-ue script inside the target directory
cat << 'EOF' > "$TARGET_SCRIPT"
#!/bin/bash

ue_id=-1

create_namespace() {
  ue_id=$1
  local name="ue$ue_id"
  echo "Creating namespace for UE ID ${ue_id}, name ${name}"
  ip netns add $name
  ip link add v-eth$ue_id type veth peer name v-ue$ue_id
  ip link set v-ue$ue_id netns $name
  
  BASE_IP=$((200+ue_id))
  ip addr add 10.$BASE_IP.1.100/24 dev v-eth$ue_id
  ip link set v-eth$ue_id up
  
  iptables -t nat -A POSTROUTING -s 10.$BASE_IP.1.0/255.255.255.0 -o lo -j MASQUERADE
  iptables -A FORWARD -i lo -o v-eth$ue_id -j ACCEPT
  iptables -A FORWARD -o lo -i v-eth$ue_id -j ACCEPT
  ip netns exec $name ip link set dev lo up

  ip netns exec $name ip addr add 10.$BASE_IP.1.$ue_id/24 dev v-ue$ue_id
  ip netns exec $name ip link set v-ue$ue_id up
  
  ip netns exec $name ip route add 127.0.0.4 via 10.$BASE_IP.1.100
  ip netns exec $name ip route add 127.0.0.5 via 10.$BASE_IP.1.100
  ip netns exec $name ip route add 127.0.0.6 via 10.$BASE_IP.1.100
  # ip netns exec $name ip route add 129.97.59.32 via 10.$BASE_IP.1.100
  
  echo "Namespace $name created."

  # Fix DNS Resolution: Copy /etc/resolv.conf into the namespace
  mkdir -p /etc/netns/$name
  cp /etc/resolv.conf /etc/netns/$name/resolv.conf

  echo "Namespace $name created with DNS resolution."
}

delete_namespace() {
  local ue_id=$1
  local name="ue$ue_id"
  echo "Deleting namespace for UE ID ${ue_id}, name ${name}"
  
  ip link delete v-eth$ue_id
  ip netns delete $name
}

list_namespaces() {
  ip netns list
}

open_namespace() {
  if [[ $ue_id -lt 1 ]]; then echo "Error: No last UE processed"; exit 1; fi
  local name="ue$ue_id"
  echo "Opening shell in namespace ${name}"
  echo "Type 'ip netns exec $name bash' in additional terminals"
  ip netns exec $name bash
}

run_command_in_namespace() {
  local ue_id=$1
  shift
  local name="ue$ue_id"
  local command="$@"
  
  if [[ -z "$command" ]]; then
    echo "Error: No command specified to run inside namespace $name."
    exit 1
  fi
  
  echo "Running command inside namespace $name: $command"
  
  # Ensuring real-time output is visible in the main shell
  sudo ip netns exec "$name" bash -c "$command 2>&1 | tee /dev/stderr"
}

usage () {
  echo "$1 -c <num>      : Create namespace 'ue<num>'"
  echo "$1 -d <num>      : Delete namespace 'ue<num>'"
  echo "$1 -e            : Execute shell in last processed namespace"
  echo "$1 -l            : List namespaces"
  echo "$1 -o <num>      : Open shell in namespace 'ue<num>'"
  echo "$1 -r <num> <cmd>: Run a command inside 'ue<num>' and show output in main shell"
}

prog_name=$(basename $0)

if [[ $(id -u) -ne 0 ]] ; then
  echo "Please run as root"
  exit 1
fi

if [[ $# -eq 0 ]]; then
  echo "Error: No parameters given"
  usage $prog_name
  exit 1
fi

while getopts c:d:ehlo:r: cmd
do
  case "${cmd}" in
    c) create_namespace ${OPTARG};;
    d) delete_namespace ${OPTARG};;
    e) open_namespace; exit;;
    h) usage ${prog_name}; exit;;
    l) list_namespaces;;
    o) ue_id=${OPTARG}; open_namespace;;
    r) ue_id=${OPTARG}; shift 2; run_command_in_namespace "$ue_id" "$@"; exit;;
    /?) echo "Invalid option"; usage ${prog_name}; exit;;
  esac
done
EOF

# Make the script executable
chmod +x "$TARGET_SCRIPT"

echo "multi-ue script successfully created at $TARGET_SCRIPT"