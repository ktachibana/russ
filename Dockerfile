FROM node:16-alpine AS build-js
COPY . /russ
WORKDIR /russ
RUN yarn install && rm -rf node_modules


FROM ruby:3.0.2-alpine AS runtime
MAINTAINER Kenichi Tachibana

COPY --from=build-js /russ /russ
WORKDIR /russ
RUN apk upgrade --no-cache && \
    apk add --update --no-cache \
      postgresql-client \
      tzdata \
      bash \
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
    gem install bundler --version=2.2.22 && \
    bundle install && \
    apk del build-dependencies

ENV RAILS_ENV=production
ENV PORT 3000
EXPOSE $PORT
ENTRYPOINT ["bundle", "exec"]
CMD ["rails", "app:server"]
