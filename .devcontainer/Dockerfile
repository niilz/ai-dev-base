ARG BASE_IMAGE="mcr.microsoft.com/devcontainers/rust:latest"
FROM ${BASE_IMAGE}

# Install fish shell, starship prompt, and dotbot
RUN apt-get update \
    && apt-get install -y --no-install-recommends fish python3-pip \
    && curl -sS https://starship.rs/install.sh | sh -s -- -y \
    && pip3 install --break-system-packages dotbot

# Switch to the vscode user
USER vscode
WORKDIR /home/vscode

# Copy dotbot config to /opt (survives the /home/vscode volume mount)
COPY --chown=vscode:vscode dotbot.yaml /opt/dotbot.yaml

# Clone dev-configs using build secret; sudo to create dir in /opt, clone as vscode
RUN --mount=type=secret,id=gitlab_key,uid=1000 \
    sudo mkdir -p /opt/dev-configs && sudo chown vscode:vscode /opt/dev-configs && \
    mkdir -p -m 0700 ~/.ssh && ssh-keyscan gitlab.com >> ~/.ssh/known_hosts && \
    GIT_SSH_COMMAND="ssh -i /run/secrets/gitlab_key -o IdentitiesOnly=yes" \
    git clone git@gitlab.com:niilz/dev-configs.git /opt/dev-configs && \
    rm -rf ~/.ssh
