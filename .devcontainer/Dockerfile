#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM ubuntu:focal

ENV SHELL=/bin/bash \
    DOCKER_BUILDKIT=1

# Mount for docker-in-docker 
VOLUME [ "/var/lib/docker" ]

RUN snap install node --classic --channel=14

# Fire Docker/Moby script
ENTRYPOINT [ "/usr/local/share/docker-init.sh", "/usr/local/share/ssh-init.sh"]
CMD [ "sleep", "infinity" ]
