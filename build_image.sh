#!/usr/bin/env bash

# Software managing containers
container_manager=

# Name of the image being built
image_name="gen2-uhf-rfid-tag-reader"

# Tag of the image
image_tag="v2023.08"

# Podman as first choice
if command -v podman >/dev/null; then
    container_manager="podman"
elif command -v docker >/dev/null; then
    container_manager="docker"
else
    read -p "No container manager installed. Would you like to install it? " -n 1 -r
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

$container_manager build . -t $image_name:$image_tag
