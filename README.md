[![Docker Image CI](https://github.com/aoudiamoncef/ubuntu-sshd/actions/workflows/ci.yml/badge.svg)](https://github.com/aoudiamoncef/ubuntu-sshd/actions/workflows/ci.yml)
[![Docker Image Deployment](https://github.com/aoudiamoncef/ubuntu-sshd/actions/workflows/cd.yml/badge.svg)](https://github.com/aoudiamoncef/ubuntu-sshd/actions/workflows/cd.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/aoudiamoncef/ubuntu-sshd.svg)](https://hub.docker.com/r/aoudiamoncef/ubuntu-sshd)
[![Maintenance](https://img.shields.io/badge/Maintained-Yes-green.svg)](https://github.com/aoudiamoncef/ubuntu-sshd)

This Docker image provides an Ubuntu 22.04 base with SSH server and Docker-in-Docker capabilities enabled. It includes a full development environment with Docker, GPU support, and common development tools. Perfect for secure containerized development environments.

## Usage

### Building the Docker Image

Build the Docker image from within the cloned repository directory:

```bash
docker build -t my-ubuntu-sshd:latest .
```

### Running a Container

To run a container based on the image, use the following command:

```bash
docker run -d \
  -p host-port:22 \
  -e SSH_USERNAME=myuser \
  -e AUTHORIZED_KEYS="$(cat path/to/authorized_keys_file)" \
  -e SSHD_CONFIG_ADDITIONAL="your_additional_config" \
  -e SSHD_CONFIG_FILE="/path/to/your/sshd_config_file" \
  my-ubuntu-sshd:latest
```

- `-d` runs the container in detached mode.
- `-p host-port:22` maps a host port to port 22 in the container. Replace `host-port` with your desired port.
- `-e SSH_USERNAME=myuser` sets the SSH username in the container. Replace `myuser` with your desired username.
  required**. Replace `mysecretpassword` with your desired password.
- `-e AUTHORIZED_KEYS="$(cat path/to/authorized_keys_file)"` sets authorized SSH keys in the container. Replace `path/to/authorized_keys_file` with the path to your authorized_keys file.
- `-e SSHD_CONFIG_ADDITIONAL="your_additional_config"` allows you to pass additional SSHD configuration. Replace
  `your_additional_config` with your desired configuration.
- `-e SSHD_CONFIG_FILE="/path/to/your/sshd_config_file"` allows you to specify a file containing additional SSHD
  configuration. Replace `/path/to/your/sshd_config_file` with the path to your configuration file.
- `my-ubuntu-sshd:latest` should be replaced with your Docker image's name and tag.

### SSH Access

Once the container is running, you can SSH into it using the following command:

```bash
ssh -p host-port myuser@localhost
```

- `host-port` should match the port you specified when running the container.
- Use the provided password or SSH key for authentication, depending on your configuration.

### Docker-in-Docker Support

This image includes Docker and supports Docker-in-Docker operations:

```bash
# Inside the SSH container, you can run Docker commands
docker run --rm hello-world
docker build -t my-app .
docker run --gpus all nvidia/cuda:12.2-base nvidia-smi
```

**Note**: For full Docker-in-Docker support, run this container with Sysbox runtime:
```bash
docker run --runtime=sysbox-runc -d -p 2222:22 \
  -e SSH_USERNAME=developer \
  -e AUTHORIZED_KEYS="$(cat ~/.ssh/id_ed25519.pub)" \
  ghcr.io/taolie-ai/ubuntu-sshd:latest
```

### Features

- **Full Development Environment**: Git, Python, Node.js, build tools
- **Docker-in-Docker**: Run Docker containers inside SSH container
- **GPU Support**: Ready for GPU workloads (with Sysbox runtime)
- **SSH Key Authentication**: Secure key-based access
- **Configurable Username**: Default `taolie`, customizable via `SSH_USERNAME`

### Note

- If the `AUTHORIZED_KEYS` environment variable is empty when starting the container, it will still launch the SSH server, but no authorized keys will be configured. You have to mount your own authorized keys file or manually configure the keys in the container.
- If `AUTHORIZED_KEYS` is provided, password authentication will be disabled for enhanced security.
- For Docker-in-Docker to work properly, use Sysbox runtime instead of standard runc.

## License

This Docker image is provided under the [MIT License](LICENSE).
