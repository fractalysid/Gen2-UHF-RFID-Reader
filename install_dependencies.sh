#!/usr/bin/env bash

# Podman is the first choice and the one installed in case there is no container manager
# Docker requires a few more steps to be setup
if command -v podman >/dev/null; then
    container_manager="podman"
    echo "* Podman found"
elif command -v docker >/dev/null; then
    container_manager="docker"
    echo "* Docker found"
else
    read -p "* No container manager installed. Would you like to install it? " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Let's find the package manager first
        package_manager=

        # Install parameters
        install_args="-y install"

        # Package name
        package_name="podman"

        if command -v apt >/dev/null; then
            package_manager="apt"
        elif command -v apt-get >/dev/null; then
            package_manager="apt-get"
        elif command -v dnf >/dev/null; then
            package_manager="dnf"
        elif command -v emerge >/dev/null; then
            package_manager="emerge"
            # empty args
            install_args=""
            package_name="app-containers/podman"
        elif command -v pacman >/dev/null; then
            package_manager="pacman"
            install_args="-S"
        elif command -v zypper >/dev/null; then
            package_manager="zypper"
            install_args="install"
        else
            echo "No supported package_manager found. Install podman/docker manually"
            exit 1
        fi

        # Let's install podman
        if sudo $package_manager $install_args $package_name; then
            echo "Podman successfully installed"
        else
            echo "Error installing podman"
            exit 1
        fi
    fi
fi

# Incrementing memory for net
echo "* Incrementing maximum socket receive/send buffer size"

# TODO: what if the system does not support configuration in /etc/sysctl.d ?
# it should be enough to check for /etc/sysctl.conf
# In that case configuration must be saved in /etc/sysctl.conf

sudo mkdir -p /etc/sysctl.d/
cat << EOF | sudo tee -a /etc/sysctl.d/net.conf
net.core.wmem_max=100000000
net.core.wmem_max=100000000
EOF

sudo sysctl -p /etc/sysctl.d/net.conf

# TODO: add support for this
#sudo ethtool -G {interface} tx 512 rx 512
