FROM node:14.17.6 as node
FROM ruby:3.2.1
COPY --from=node /opt/yarn-* /opt/yarn
COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules/ /usr/local/lib/node_modules/
RUN ln -fs /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -fs /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npx \
  && ln -fs /opt/yarn/bin/yarn /usr/local/bin/yarn \
  && ln -fs /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg


RUN set -eux \
	&& apt-get update \
	&& apt-get install -y gosu \
	&& rm -rf /var/lib/apt/lists/* \
# verify that the binary works
	&& gosu nobody true
RUN useradd -G sudo --user-group --create-home --shell /bin/false app \
  && chown -R $USER:$USER db log storage tmp \
  && echo 'app:apppass' | chpasswd \
  && curl https://cli-assets.heroku.com/install.sh | sh \
  && apt-get install -y gobject-introspection \
  libvips \
  ffmpeg \
  poppler-utils \
  build-essential \
  libpq-dev \
  libgirepository1.0-dev \
  postgresql-client \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

USER $USER:$USER
RUN mkdir /myapp
WORKDIR /myapp

COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN gem install bundler
RUN bundle install

COPY package.json yarn.lock ./
RUN yarn install

COPY . /myapp

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
