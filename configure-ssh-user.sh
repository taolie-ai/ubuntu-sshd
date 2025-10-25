#!/bin/bash

# Set default values for SSH_USERNAME if not provided
: ${SSH_USERNAME:=taolie}
: ${SSHD_CONFIG_ADDITIONAL:=""}

# Create the user with the provided username and set the password
if id "$SSH_USERNAME" &>/dev/null; then
    echo "User $SSH_USERNAME already exists"
else
    useradd -ms /bin/bash "$SSH_USERNAME"
    echo "User $SSH_USERNAME created"
fi

# Add to sudo and docker groups
usermod -aG sudo "$SSH_USERNAME"
usermod -aG docker "$SSH_USERNAME"
echo "User $SSH_USERNAME added to sudo and docker groups"

echo "$SSH_USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$SSH_USERNAME
chmod 0440 /etc/sudoers.d/$SSH_USERNAME

# Set the authorized keys from the AUTHORIZED_KEYS environment variable (if provided)
if [ -n "$AUTHORIZED_KEYS" ]; then
    mkdir -p /home/$SSH_USERNAME/.ssh
    echo "$AUTHORIZED_KEYS" > /home/$SSH_USERNAME/.ssh/authorized_keys
    chown -R $SSH_USERNAME:$SSH_USERNAME /home/$SSH_USERNAME/.ssh
    chmod 700 /home/$SSH_USERNAME/.ssh
    chmod 600 /home/$SSH_USERNAME/.ssh/authorized_keys
    echo "Authorized keys set for user $SSH_USERNAME"
fi

# Apply additional SSHD configuration if provided
if [ -n "$SSHD_CONFIG_ADDITIONAL" ]; then
    echo "$SSHD_CONFIG_ADDITIONAL" >> /etc/ssh/sshd_config
    echo "Additional SSHD configuration applied"
fi

# Apply additional SSHD configuration from a file if provided
if [ -n "$SSHD_CONFIG_FILE" ] && [ -f "$SSHD_CONFIG_FILE" ]; then
    cat "$SSHD_CONFIG_FILE" >> /etc/ssh/sshd_config
    echo "Additional SSHD configuration from file applied"
fi

# Configure Docker to use NVIDIA runtime
echo "Configuring Docker for NVIDIA support..."
mkdir -p /etc/docker
cat > /etc/docker/daemon.json << EOF
{
  "runtimes": {
    "nvidia": {
      "path": "nvidia-container-runtime",
      "runtimeArgs": []
    }
  },
  "default-runtime": "nvidia"
}
EOF

# Start Docker daemon in background
echo "Starting Docker daemon..."
dockerd > /var/log/dockerd.log 2>&1 &

# Wait a moment for Docker to start
sleep 5

# Start the SSH server
echo "Starting SSH server..."
exec /usr/sbin/sshd -D
