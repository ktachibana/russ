FROM node:14-alpine AS build-js
COPY . /russ
WORKDIR /russ
RUN yarn install && rm -rf node_modules


FROM ruby:3.0.0-alpine AS runtime
MAINTAINER Kenichi Tachibana

COPY --from=build-js /russ /russ
WORKDIR /russ
RUN apk upgrade --no-cache && \
    apk add --update --no-cache \
      postgresql-client \
      tzdata \
      bash \
      nginx \
      xz-dev && \
    apk add --update --no-cache --virtual=build-dependencies \
      build-base \
      curl-dev \
      linux-headers \
      libxml2-dev \
      libxslt-dev \
      postgresql-dev \
      ruby-dev \
      yaml-dev \
      zlib-dev && \
    gem uninstall bundler && \
    gem install bundler --version=2.2.3 && \
    bundle install && \
    apk del build-dependencies

COPY containers/rproxy/nginx.conf /etc/nginx/
COPY containers/rproxy/conf.d/default.conf /etc/nginx/conf.d/
RUN mkdir /run/nginx


ENV RAILS_ENV=production
ENTRYPOINT ["bundle", "exec"]
CMD ["rails", "app:server"]
EXPOSE 3000
