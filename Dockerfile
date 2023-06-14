# syntax=docker/dockerfile:1
FROM debian:stable-slim

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Increase the file watcher limit for node. This should not be necessary for CI builds since watchers should be disabled, but it can be useful when running this image in a local environment.
RUN echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf

RUN apt-get update \
    && apt-get install -y curl \
    && apt-get install -y git \
    && apt-get install -y php-cli \
    && apt-get install -y php-mbstring \
    && apt-get -y autoclean

SHELL ["/bin/bash", "--login", "-c"]

# Install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
RUN nvm install lts/*

# Caches `.npm` folder in the image, so future `npm install/ci` actions are faster for `gutenberg-mobile` project
RUN git clone https://github.com/wordpress-mobile/gutenberg-mobile.git /var/gutenberg-mobile --depth 1 \
    && pushd /var/gutenberg-mobile \
    && git submodule update --init --recursive  \
    && nvm install \
    && npm ci --no-audit --no-progress --unsafe-perm \
    && popd \
    && rm -rf /var/gutenberg-mobile

# Add CI toolkit
#
# Using HTTPS to clone because there's no SSH key in the image
RUN git clone https://github.com/Automattic/a8c-ci-toolkit-buildkite-plugin /ci-toolkit
# Add ci-toolkit to the PATH
RUN echo 'export PATH="$PATH:/ci-toolkit/bin"' >> ~/.bashrc

# Install AWS CLI
RUN apt-get install -y unzip
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscli.zip" && \
    unzip awscli.zip && \
    ./aws/install

# Install jq
RUN apt-get install -y jq
