#!/bin/bash

# Define the list of packages to install
packages=(
    autoconf
    automake
    build-essential
    ccache
    cmake
    cpufrequtils
    doxygen
    ethtool
    g++
    git
    inetutils-tools
    libboost-all-dev
    libncurses-dev
    libusb-1.0-0
    libusb-1.0-0-dev
    libusb-dev
    python3-dev
    python3-mako
    python3-numpy
    python3-requests
    python3-scipy
    python3-setuptools
    python3-ruamel.yaml
)

# Install the packages
echo "Installing packages..."
sudo apt install -y "${packages[@]}"

# Check if the installation was successful
if [[ $? -eq 0 ]]; then
    echo "All packages installed successfully."
else
    echo "Some packages failed to install. Please check the errors above."
fi