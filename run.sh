#!/usr/bin/env bash

# This should be kept syncronized with the script building the image

# Name of the image
image_name="gen2-uhf-rfid-tag-reader"

# Tag of the image
#image_tag="v2023.08"
image_tag="v1"

# Right now we need an interactive shell as the python script relies on user
# input to quit the infinite loop

podman run -it localhost/$image_name:$image_tag
