#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

set -e

USERNAME="codespace"
USER_UID="1000"
USER_GID="1000"

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get -y install --no-install-recommends \
    apt-utils \
    locales \
    sudo \
    git \
    init-system-helpers
apt-get -y clean 
rm -rf /var/lib/apt/lists/*

group_name="${USERNAME}"
groupadd --gid $USER_GID $USERNAME
useradd -s /bin/bash --uid $USER_UID --gid $USERNAME -m $USERNAME

if [ "${USERNAME}" != "root" ] && [ "${EXISTING_NON_ROOT_USER}" != "${USERNAME}" ]; then
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
    chmod 0440 /etc/sudoers.d/$USERNAME
    EXISTING_NON_ROOT_USER="${USERNAME}"
fi

# *********************************
# ** Shell customization section **
# *********************************

FEATURE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
user_rc_path="/home/${USERNAME}"
cat "${FEATURE_DIR}/scripts/bash_theme_snippet.sh" >> "${user_rc_path}/.bashrc"
chown ${USERNAME}:${group_name} "${user_rc_path}/.bashrc"

# ****************************
# ** Utilities and commands **
# ****************************

HOME_DIR="/home/${USERNAME}/"
chown -R ${USERNAME}:${USERNAME} ${HOME_DIR}
chmod -R g+r+w "${HOME_DIR}"
find "${HOME_DIR}" -type d | xargs -n 1 chmod g+s

OPT_DIR="/opt/"
chmod -R g+r+w "${OPT_DIR}"
find "${OPT_DIR}" -type d | xargs -n 1 chmod g+s

echo "Done!"
