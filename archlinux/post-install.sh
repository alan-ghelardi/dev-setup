#!/usr/bin/env bash

set -euo pipefail

# Add my user to the audio group.
# Although not recommended, this seems necessary to enable Emacspeak.
usermod  -aG docker $USER

# Add my user to the Docker group
usermod  -aG docker $USER

# Enable accessibility settings on Mate
gsettings set org.mate.interface accessibility true
