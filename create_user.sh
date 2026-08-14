#!/bin/bash

# If not provided, defaults to "ubuntu" with UID and GID of 1000
USER=${USER:-"ubuntu"}
USER_ID=${USER_ID:-1000}
GROUP_ID=${GROUP_ID:-1000}

# Create group only if it doesn't already exist
if ! getent group "$GROUP_ID" > /dev/null 2>&1; then
    groupadd -g "$GROUP_ID" "$USER"
fi

# Create user only if it doesn't already exist
if ! getent passwd "$USER_ID" > /dev/null 2>&1; then
    useradd -m -s /bin/bash -u "$USER_ID" -g "$GROUP_ID" "$USER"
fi

# Add the user to sudo group
apt-get update
apt-get -qq install sudo
usermod -aG sudo "$USER"

# Add user to sudoers without password
echo "${USER} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/"$USER"
chmod 0440 /etc/sudoers.d/"$USER"
