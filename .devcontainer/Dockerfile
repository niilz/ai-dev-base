ARG BASE_IMAGE="mcr.microsoft.com/devcontainers/rust:trixie"
#ARG BASE_IMAGE=ubuntu:26.04
FROM ${BASE_IMAGE}

# The umbrella issue (Optional Cisco root certificate)
RUN --mount=type=bind,target=/tmp/build-context \
    bash /tmp/build-context/scripts/setup-cisco-cert.sh /tmp/build-context

# Remove untrusted eMudhra certs
RUN apt-get update && \
    apt-get install -y --no-install-recommends --only-upgrade ca-certificates && \
    rm -f /usr/share/ca-certificates/mozilla/emSign_ECC_Root_CA_-_G3.crt \
          /usr/share/ca-certificates/mozilla/AAA_Certificate_Services.crt && \
    sed -i '/emSign_ECC_Root_CA_-_G3/d; /AAA_Certificate_Services/d' /etc/ca-certificates.conf && \
    update-ca-certificates --fresh && \
    rm -rf /var/lib/apt/lists/*

# Install prerequisites
RUN apt-get update \
    && apt-get install -y --no-install-recommends adb fish fzf pipx unzip \
    && curl -sS https://starship.rs/install.sh | sh -s -- -y \
    && curl -fsSL https://herdr.dev/install.sh | HERDR_INSTALL_DIR=/usr/local/bin sh \
    && PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install dotbot

# Install Neovim natively (supports arm64 and x86_64)
ARG NVIM_VERSION=stable
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "aarch64" ]; then NVIM_ARCH="arm64"; else NVIM_ARCH="x86_64"; fi && \
    curl -sL "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-${NVIM_ARCH}.tar.gz" -o nvim.tar.gz && \
    mkdir -p /opt/nvim && \
    tar -xzf nvim.tar.gz -C /opt/nvim --strip-components=1 && \
    ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim && \
    rm nvim.tar.gz

# Install Lua Language Server
ARG LUA_LS_VERSION=3.18.2
RUN curl -sL "https://github.com/LuaLS/lua-language-server/releases/download/${LUA_LS_VERSION}/lua-language-server-${LUA_LS_VERSION}-linux-x64.tar.gz" -o lua-language-server.tar.gz \
    && mkdir -p /opt/lua-language-server \
    && tar -xzf lua-language-server.tar.gz -C /opt/lua-language-server \
    && ln -s /opt/lua-language-server/bin/lua-language-server /usr/local/bin/lua-language-server \
    && rm lua-language-server.tar.gz

# Install JADX Headless MCP
ARG JADX_MCP_VERSION=0.7.1
RUN mkdir -p /opt/jadx && \
    curl -sL "https://github.com/1013503897/jadx-headless-mcp/releases/download/v${JADX_MCP_VERSION}/jadx-headless-mcp-${JADX_MCP_VERSION}-all.jar" \
         -o /opt/jadx/jadx-headless-mcp.jar && \
    chmod 644 /opt/jadx/jadx-headless-mcp.jar

# Clone dev-configs using build secret as root
RUN --mount=type=secret,id=gitlab_key \
    mkdir -p -m 0700 ~/.ssh && ssh-keyscan gitlab.com >> ~/.ssh/known_hosts && \
    GIT_SSH_COMMAND="ssh -i /run/secrets/gitlab_key -o IdentitiesOnly=yes" \
    git clone git@gitlab.com:niilz/dev-configs.git /opt/dev-configs && \
    rm -rf ~/.ssh

# Switch to the vscode user
USER vscode
WORKDIR /home/vscode

# Ensure directory is created with vscode ownership before bind mounts attach
RUN mkdir -p /home/vscode/.local/share

# herdr keeps its session state (session.json, snapshots) next to its Unix
# sockets in ~/.config/herdr. We persist it via a named Docker volume rather
# than a host bind mount, because sockets on macOS bind mounts are unreliable.
# Docker copies the ownership of an existing image directory into a fresh
# volume, so pre-creating it here keeps the volume writable for vscode
# (otherwise it would be owned by root).
RUN mkdir -p /home/vscode/.config/herdr
ENV PNPM_HOME="/home/vscode/.local/share/pnpm"
ENV PATH="$PNPM_HOME/bin:$PATH"

# Copy dotbot config and post-create script to /opt so they are available
# when starting the container via aidev.fish (--config) in projects without .devcontainer/
COPY --chown=vscode:vscode dotbot.yaml /opt/dotbot.yaml
COPY --chown=vscode:vscode --chmod=0755 scripts/post-create.sh /opt/post-create.sh
