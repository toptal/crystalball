ARG RUBY_VERSION
FROM ruby:$RUBY_VERSION

ARG BUNDLER_VERSION

# Install micro editor
RUN cd /usr/local/bin \
  && curl -sL https://getmic.ro | bash

# Install dependencies
# RUN apt-get update -qq \
#     && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade \
#     && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
#       build-essential \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
#     && truncate -s 0 /var/log/*log

# Configure bundler and PATH
ENV LANG=C.UTF-8 \
  GEM_HOME=/bundle \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3
ENV BUNDLE_PATH $GEM_HOME
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH \
  BUNDLE_BIN=$BUNDLE_PATH/bin
ENV PATH /crystalball/bin:$BUNDLE_BIN:$PATH

# Upgrade RubyGems and install required Bundler version
RUN gem update --system && \
  gem install bundler:$BUNDLER_VERSION && \
  git config --global user.email "john.doe@example.com" && \
  git config --global user.name "John Doe"

WORKDIR /crystalball
