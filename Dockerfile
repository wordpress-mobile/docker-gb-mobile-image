# syntax=docker/dockerfile:1
FROM debian:stable-slim

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Increase the file watcher limit for node. This should not be necessary for CI builds since watchers should be disabled, but it can be useful when running this image in a local environment. 
RUN echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf

RUN apt-get update \
    && apt-get install -y curl git \
    && apt-get -y autoclean

SHELL ["/bin/bash", "--login", "-c"]

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
RUN nvm install lts/*

# Caches `.npm` folder in the image, so future `npm install/ci` actions are faster for `gutenberg-mobile` project
RUN git clone https://github.com/wordpress-mobile/gutenberg-mobile.git /var/gutenberg-mobile --depth 1 \
    && pushd /var/gutenberg-mobile \
    && git submodule update --init --recursive  \
    && npm ci --no-audit --no-progress --unsafe-perm \
    && popd \
    && rm -rf /var/gutenberg-mobile
