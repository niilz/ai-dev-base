ARG BASE_IMAGE="mcr.microsoft.com/devcontainers/rust:latest"
FROM ${BASE_IMAGE}

# Install prerequisites
RUN apt-get update \
    && apt-get install -y --no-install-recommends fish fzf pipx unzip \
    && curl -sS https://starship.rs/install.sh | sh -s -- -y \
    && PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install dotbot

# Install Lua Language Server
ARG LUA_LS_VERSION=3.18.2
RUN curl -sL "https://github.com/LuaLS/lua-language-server/releases/download/${LUA_LS_VERSION}/lua-language-server-${LUA_LS_VERSION}-linux-x64.tar.gz" -o lua-language-server.tar.gz \
    && mkdir -p /opt/lua-language-server \
    && tar -xzf lua-language-server.tar.gz -C /opt/lua-language-server \
    && ln -s /opt/lua-language-server/bin/lua-language-server /usr/local/bin/lua-language-server \
    && rm lua-language-server.tar.gz

# Install Neovim natively (supports arm64 and amd64)
ARG NVIM_VERSION=v0.12.4
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "aarch64" ]; then NVIM_ARCH="linux-arm64"; else NVIM_ARCH="linux64"; fi && \
    curl -sL "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-${NVIM_ARCH}.tar.gz" -o nvim.tar.gz && \
    tar -xzf nvim.tar.gz -C /opt && \
    ln -s /opt/nvim-${NVIM_ARCH}/bin/nvim /usr/local/bin/nvim && \
    rm nvim.tar.gz

# Clone dev-configs using build secret as root
RUN --mount=type=secret,id=gitlab_key \
    mkdir -p -m 0700 ~/.ssh && ssh-keyscan gitlab.com >> ~/.ssh/known_hosts && \
    GIT_SSH_COMMAND="ssh -i /run/secrets/gitlab_key -o IdentitiesOnly=yes" \
    git clone git@gitlab.com:niilz/dev-configs.git /opt/dev-configs && \
    rm -rf ~/.ssh

# Switch to the vscode user
USER vscode
WORKDIR /home/vscode

# Copy dotbot config to /opt (survives the /home/vscode volume mount)
COPY --chown=vscode:vscode dotbot.yaml /opt/dotbot.yaml
