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
    RBENV_VERSION=${RUBY_VERSION} \
    RBENV_HOME=/usr/local/vsts-agent/.rbenv \
    RBENV_SHIMS=${RBENV_HOME}/shims \
    RUBY_HOME=${RBENV_HOME}/versions/${RUBY_VERSION} \
    RUBY_BIN=${RUBY_HOME}/bin \
    CONFIGURE_OPTS=--disable-install-doc
    #PATH=${RBENV_SHIMS}:${RBENV_HOME}/bin:$PATH

ENV rbenv=${RBENV_HOME}/bin/rbenv \
    ruby=${RBENV_SHIMS}/ruby \
    gem=${RBENV_SHIMS}/gem \
    bundle=${RBENV_SHIMS}/bundle

# TODO where is bundle installed?


# Install rbenv
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv
#RUN export HOME=/usr/local/vsts-agent
RUN echo 'export PATH=:~/.rbenv/bin:$PATH' >> ~/.bashrc
RUN echo 'eval "$(rbenv init -)"' >> ~/.bashrc


# Install ruby-build (for install ruby)
RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# Install Ruby, Bundler, and Rubocop
RUN echo "###### PATH ######"
RUN bash -c "echo $PATH | tr : '\n'"
RUN bash -c "source ~/.bashrc && type rbenv"
RUN bash -l -c "\
    source ~/.bashrc && \
    rbenv install ${RUBY_VERSION}; \
    gem install bundler \
    gem install rubocop"


ENV AGENT_FLAVOR=Ruby
