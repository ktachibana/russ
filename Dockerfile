FROM ruby:2.3.1
MAINTAINER Kenichi Tachibana

RUN apt-get update -qq && apt-get -y install \
  libpq-dev \
  nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /russ
COPY Gemfile Gemfile.lock .ruby-version /russ/
RUN bundle install --without test development

COPY . /russ

ENV RAILS_ENV=production

ENTRYPOINT ["bundle", "exec"]
CMD ["unicorn_rails", "-c", "config/unicorn.rb"]

EXPOSE 8080
