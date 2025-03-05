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
  echo "creating namespace for UE ID ${ue_id} name ${name}"
  ip netns add $name
  ip link add v-eth$ue_id type veth peer name v-ue$ue_id
  ip link set v-ue$ue_id netns $name
  BASE_IP=$((200+ue_id))
  ip addr add 10.$BASE_IP.1.100/24 dev v-eth$ue_id
  ip link set v-eth$ue_id up
  iptables -t nat -A POSTROUTING -s 10.$BASE_IP.1.0/255.255.255.0 -o lo -j MASQUERADE
  iptables -A FORWARD -i lo -o v-eth$ue_id -j ACCEPT
}
EOF

# Make the script executable
chmod +x "$TARGET_SCRIPT"

echo "multi-ue script successfully created at $TARGET_SCRIPT"