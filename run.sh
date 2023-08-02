#!/usr/bin/env bash

# These names should be kept synchronized with the script building the image

# Name of the image
image_name="gen2-uhf-rfid-tag-reader"

# Tag of the image
image_tag="v2023.08"

# Right now we need an interactive shell as the python script relies on user
# input to quit the infinite loop

podman run -it --rm --env-file ./configuration.env \
    --cap-add=sys_nice \
    --network=host \
    --name tag_reader \
    localhost/$image_name:$image_tag