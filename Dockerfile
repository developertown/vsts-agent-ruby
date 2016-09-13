FROM developertown/vsts-agent:2.105.2-7

WORKDIR /usr/local/vsts-agent

# our vsts user can't apt-get install
USER root

########################################################
# debconf: unable to initialize frontend: Dialog
# https://github.com/phusion/baseimage-docker/issues/58
########################################################
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=linux

# common dependencies for various gems
RUN apt-get update
RUN apt-get install \
    openssl libreadline6 libreadline6-dev zlib1g zlib1g-dev \
    libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev \
    autoconf libc6-dev automake \
    --assume-yes

USER vsts

###################################################################
# As of Dec 2014, you cannot evaluate shell commands at build time.
# http://stackoverflow.com/a/27711465/356849
# (Otherwise, for the exec paths, you could just do `which ruby`)
###################################################################

ENV RUBY_VERSION=2.3.1 \
    RVM_HOME=/usr/local/vsts-agent/.rvm \
    LATEST_RUBY_HOME=${RVM_HOME}/rubies/ruby-${RUBY_VERSION} \
    rvm=${RVM_HOME}/scripts/rvm \
    ruby=${LATEST_RUBY_HOME}/bin/ruby \
    gem=${LATEST_RUBY_HOME}/bin/gem \
    bundle=${LATEST_RUBY_HOME}/bin/bundle \
    rubocop=${LATEST_RUBY_HOME}/bin/rubocop \
    PATH=$PATH:${LATEST_RUBY_HOME}

# Install RVM
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN curl -sSL https://get.rvm.io | bash

# Install Ruby, Bundler, and Rubocop
RUN /bin/bash -c "\
                    source ~/.rvm/scripts/rvm \
                    && rvm autolibs disable \
                    && rvm install ${RUBY_VERSION} \
                    && rvm use ${RUBY_VERSION} \
                    && gem install bundler --no-ri --no-rdoc \
                    && gem install rubocop --no-ri --no-rdoc"

ENV AGENT_FLAVOR=Ruby

RUN echo $PATH
