#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

USERNAME="codespace"
USER_UID="1000"
USER_GID="1000"

set -e

MARKER_FILE="/usr/local/etc/vscode-dev-containers/common"

FEATURE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


# Load markers to see which steps have already run
if [ -f "${MARKER_FILE}" ]; then
    echo "Marker file found:"
    cat "${MARKER_FILE}"
    source "${MARKER_FILE}"
fi


# Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
. /etc/os-release

# Get an adjusted ID independant of distro variants
ADJUSTED_ID="debian"
export DEBIAN_FRONTEND=noninteractive

package_list="apt-utils \
    locales \
    sudo \
    git \
    init-system-helpers"

# Install the list of packages
echo "Packages to verify are installed: ${package_list}"
rm -rf /var/lib/apt/lists/*
apt-get update -y
apt-get -y install --no-install-recommends ${package_list}

# Clean up
apt-get -y clean 
rm -rf /var/lib/apt/lists/*

# Create or update a non-root user to match UID/GID.
group_name="${USERNAME}"
if id -u ${USERNAME} > /dev/null 2>&1; then
    # User exists, update if needed
    if [ "${USER_GID}" != "automatic" ] && [ "$USER_GID" != "$(id -g $USERNAME)" ]; then 
        group_name="$(id -gn $USERNAME)"
        groupmod --gid $USER_GID ${group_name}
        usermod --gid $USER_GID $USERNAME
    fi
    if [ "${USER_UID}" != "automatic" ] && [ "$USER_UID" != "$(id -u $USERNAME)" ]; then 
        usermod --uid $USER_UID $USERNAME
    fi
else
    # Create user
    if [ "${USER_GID}" = "automatic" ]; then
        groupadd $USERNAME
    else
        groupadd --gid $USER_GID $USERNAME
    fi
    if [ "${USER_UID}" = "automatic" ]; then 
        useradd -s /bin/bash --gid $USERNAME -m $USERNAME
    else
        useradd -s /bin/bash --uid $USER_UID --gid $USERNAME -m $USERNAME
    fi
fi

# Add add sudo support for non-root user
if [ "${USERNAME}" != "root" ] && [ "${EXISTING_NON_ROOT_USER}" != "${USERNAME}" ]; then
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
    chmod 0440 /etc/sudoers.d/$USERNAME
    EXISTING_NON_ROOT_USER="${USERNAME}"
fi

# *********************************
# ** Shell customization section **
# *********************************

user_rc_path="/home/${USERNAME}"

global_rc_path="/etc/bash.bashrc"
cat "${FEATURE_DIR}/scripts/rc_snippet.sh" >> ${global_rc_path}
cat "${FEATURE_DIR}/scripts/bash_theme_snippet.sh" >> "${user_rc_path}/.bashrc"
cat "${FEATURE_DIR}/scripts/bash_theme_snippet.sh" >> "/root/.bashrc"
chown ${USERNAME}:${group_name} "${user_rc_path}/.bashrc"
RC_SNIPPET_ALREADY_ADDED="true"

# ****************************
# ** Utilities and commands **
# ****************************

# Persist image metadata info, script if meta.env found in same directory
if [ -f "/usr/local/etc/vscode-dev-containers/meta.env" ]; then
    cp -f "${FEATURE_DIR}/bin/devcontainer-info" /usr/local/bin/devcontainer-info
    chmod +x /usr/local/bin/devcontainer-info
fi

# Write marker file
if [ ! -d "/usr/local/etc/vscode-dev-containers" ]; then
    mkdir -p "$(dirname "${MARKER_FILE}")"
fi

# Ensure that login shells get the correct path if the user updated the PATH using ENV.
rm -f /etc/profile.d/00-restore-env.sh
echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" > /etc/profile.d/00-restore-env.sh
chmod +x /etc/profile.d/00-restore-env.sh

export DEBIAN_FRONTEND=noninteractive

HOME_DIR="/home/${USERNAME}/"
chown -R ${USERNAME}:${USERNAME} ${HOME_DIR}
chmod -R g+r+w "${HOME_DIR}"
find "${HOME_DIR}" -type d | xargs -n 1 chmod g+s

OPT_DIR="/opt/"
chmod -R g+r+w "${OPT_DIR}"
find "${OPT_DIR}" -type d | xargs -n 1 chmod g+s

echo "Done!"
