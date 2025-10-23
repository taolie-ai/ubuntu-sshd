FROM ubuntu:22.04

# Install OpenSSH server, Docker, sudo, and common development tools
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    openssh-server \
    docker.io \
    sudo \
    iproute2 \
    iputils-ping \
    telnet \
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    tree \
    unzip \
    zip \
    build-essential \
    python3 \
    python3-pip \
    nodejs \
    npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure SSH
RUN mkdir -p /run/sshd \
    && chmod 755 /run/sshd \
    && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config \
    && echo "PasswordAuthentication no" >> /etc/ssh/sshd_config \
    && echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config

# Copy the script to configure the user and start services
COPY configure-ssh-user.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/configure-ssh-user.sh

EXPOSE 22

CMD ["/usr/local/bin/configure-ssh-user.sh"]
