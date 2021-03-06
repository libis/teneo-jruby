# Base image
ARG RUBY_VERSION=9-jdk

FROM jruby:${RUBY_VERSION}

# Silence apt
RUN dpkg-reconfigure debconf --frontend=noninteractive

# Install common packages
RUN apt-get update -qq \
    && apt-get install -qqy --no-install-recommends \
        build-essential \
        gnupg2 \
        curl \
        less \
        git \
        wget \
        libaio1 \
        vim \
    && apt-get clean \
    && rm -fr /var/cache/apt/archives/* \
    && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp* \
    && truncate -s 0 /var/log/*log

# Install some Rails requirements NodeJS and yarn

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update -qq \
    && apt-get install -qqy --no-install-recommends \
        nodejs \
        yarn \
    && apt-get clean \
    && rm -fr /var/cache/apt/archives/* \
    && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp* \
    && truncate -s 0 /var/log/*log

ARG PG_VERSION=12

# Upgrade RubyGems and install required Bundler version
ARG BUNDLER_VERSION=2.1.4

RUN gem update --system && \
    gem install bundler:$BUNDLER_VERSION

# Copy Entrypoint script
COPY start.sh /usr/local/bin/start.sh
RUN chmod 755 /usr/local/bin/start.sh

# Location of the installed gems
ARG GEMS_PATH=/bundle-gems
VOLUME ${GEMS_PATH}

# Prepare ruby environment
ENV LANG=C.UTF-8 \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    BUNDLE_PATH=${GEMS_PATH} \
    RUBY_ENV=production

ENTRYPOINT [ "/usr/local/bin/start.sh" ]
CMD [ "bundle", "exec", "irb" ]
