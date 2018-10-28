FROM ruby:2.4.1
MAINTAINER Kenichi Tachibana

RUN apt-get update -qq && apt-get -y install \
  libpq-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY . /russ
WORKDIR /russ
RUN gem install bundler --version=1.16.1 && bundle install --without test development

ENV RAILS_ENV=production

ENTRYPOINT ["bundle", "exec"]
CMD ["rails", "app:server"]

EXPOSE 3000
