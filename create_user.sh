#!/bin/bash

# If not provided, defaults to "ubuntu" with UID and GID of 1000
USER=${USER:-"ubuntu"}
USER_ID=${USER_ID:-1000}
GROUP_ID=${GROUP_ID:-1000}

# Create user
# Ubuntu 24.04 base images already ship a "ubuntu" user/group at 1000:1000,
# so reuse the existing group/account if it already occupies the requested
# GID/UID instead of failing on groupadd/useradd.
if getent group "$GROUP_ID" >/dev/null 2>&1; then
    CURRENT_GROUP_NAME=$(getent group "$GROUP_ID" | cut -d: -f1)
    [ "$CURRENT_GROUP_NAME" = "$USER" ] || groupmod -n "$USER" "$CURRENT_GROUP_NAME"
else
groupadd -g "$GROUP_ID" "$USER"
fi

if getent passwd "$USER_ID" >/dev/null 2>&1; then
    CURRENT_USER_NAME=$(getent passwd "$USER_ID" | cut -d: -f1)
    [ "$CURRENT_USER_NAME" = "$USER" ] || usermod -l "$USER" -d "/home/$USER" -m "$CURRENT_USER_NAME"
    usermod -g "$GROUP_ID" -s /bin/bash "$USER"
else
useradd -m -s /bin/bash -u "$USER_ID" -g "$GROUP_ID" "$USER"
fi

# Add the user to sudo group
apt-get update
apt-get -qq install sudo
usermod -aG sudo "$USER"

# Add user to sudoers without password
echo "${USER} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/"$USER"
chmod 0440 /etc/sudoers.d/"$USER"
