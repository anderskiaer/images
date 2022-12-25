#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM alpine:latest

COPY first-run-notice.txt /tmp/scripts/

# Install basic build tools
RUN LANG="C.UTF-8" \
    && apt-get update \
    && apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        git \
    && rm -rf /var/lib/apt/lists/* \
    # Move first run notice to right spot
    && mkdir -p "/usr/local/etc/vscode-dev-containers/" \
    && mv -f /tmp/scripts/first-run-notice.txt /usr/local/etc/vscode-dev-containers/ \
    # Remove scripts now that we're done with them
    && apt-get autoremove -y \
    && apt-get clean -y

# Default to bash shell (other shells available at /usr/bin/fish and /usr/bin/zsh)
ENV SHELL=/bin/bash \
    DOCKER_BUILDKIT=1

# Mount for docker-in-docker 
VOLUME [ "/var/lib/docker" ]

# Fire Docker/Moby script if needed
ENTRYPOINT [ "/usr/local/share/docker-init.sh", "/usr/local/share/ssh-init.sh"]
CMD [ "sleep", "infinity" ]
