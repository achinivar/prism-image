#!/bin/bash

#The set command below turns on strict bash mode for the script:
#-o u - error on unset variables
#-e - exit as soon as any command fails
#-x - print each command as it runs (useful in build logs)
#pipefail - a pipeline fails if any command in it fails, not just the last one
set -ouex pipefail

# Enable the llama.cpp server and path units (path starts the service when the model file appears)
systemctl enable llama-server.path
systemctl enable llama-server.service
