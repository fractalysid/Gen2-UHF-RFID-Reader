#!/usr/bin/env bash

# Software managing containers
container_manager=

# Name of the image being built
image_name="gen2-uhf-rfid-tag-reader"

# Tag of the image
image_tag="v2023.08"

if command -v podman >/dev/null; then
    container_manager="podman"
elif command -v docker >/dev/null; then
    container_manager="docker"
else
    echo "No container manager installed. Run ./install_dependencies.sh"
    exit 1
fi

# TODO: directly use the github url as context for building
# add --no-cache to disable caching to reduce disk space utilization but subsequent
# builds will always take the same time

$container_manager build --build-arg-file ./build.env . -t $image_name:$image_tag

# Take into account that the podman version installed may not support the
# --build-arg-file option
# Other errors are not considered
if [ $? -ne 0 ]; then
    echo "- $container_manager does not support --build-arg-file. Running with custom options"
    $container_manager build --build-arg SLOTS=0 --build-arg QUERIES=1000 . -t $image_name:$image_tag
fi
