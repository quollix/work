FROM ubuntu:24.04

ARG GO_VERSION=1.26.2
ARG GOFUMPT_VERSION=v0.9.2
ARG SHFMT_VERSION=v3.13.1
ARG STATICCHECK_VERSION=v0.7.0
ARG YQ_VERSION=v4.53.2

ENV DEBIAN_FRONTEND=noninteractive
ENV NPM_CONFIG_UPDATE_NOTIFIER=false
ENV SHARED_TOOLS_ROOT=/opt/work-tools

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        bubblewrap \
        build-essential \
        ca-certificates \
        curl \
        bat \
        fd-find \
        file \
        git \
        gh \
        git-delta \
        jq \
        less \
        nodejs \
        npm \
        openssh-client \
        procps \
        ripgrep \
        rsync \
        shellcheck \
        sqlite3 \
        tar \
        tree \
        util-linux \
        unzip \
        xz-utils \
        zip \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/batcat /usr/local/bin/bat \
    && ln -s /usr/bin/fdfind /usr/local/bin/fd

RUN mkdir -p \
        /home/work/workspace \
        /home/work/.codex/skills \
        /home/work/.cache \
        /home/work/.local/share \
        /opt/image-tools \
        /opt/work-tools

RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tgz \
    && rm -rf /usr/local/go \
    && tar -C /usr/local -xzf /tmp/go.tgz \
    && rm -f /tmp/go.tgz \
    && /usr/local/go/bin/go version \
    && GOBIN=/usr/local/bin /usr/local/go/bin/go install "github.com/mikefarah/yq/v4@${YQ_VERSION}" \
    && GOBIN=/usr/local/bin /usr/local/go/bin/go install "mvdan.cc/sh/v3/cmd/shfmt@${SHFMT_VERSION}" \
    && GOBIN=/usr/local/bin /usr/local/go/bin/go install "mvdan.cc/gofumpt@${GOFUMPT_VERSION}" \
    && GOBIN=/usr/local/bin /usr/local/go/bin/go install "honnef.co/go/tools/cmd/staticcheck@${STATICCHECK_VERSION}" \
    && npm install -g --prefix /opt/image-tools/npm-global @openai/codex@latest

VOLUME ["/home/work/.codex", "/opt/work-tools"]
   
COPY entrypoint.sh /usr/local/bin/work-codex-entrypoint

ENTRYPOINT ["/usr/local/bin/work-codex-entrypoint"]
