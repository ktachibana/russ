FROM ruby:2.4.1
MAINTAINER Kenichi Tachibana

RUN apt-get update -qq && apt-get -y install \
  libpq-dev \
  nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /russ
COPY Gemfile Gemfile.lock .ruby-version /russ/
RUN gem install bundler --version=1.16.1 && bundle install --without test development

COPY . /russ

ENV RAILS_ENV=production

ENTRYPOINT ["bundle", "exec"]
CMD ["rake", "app:server"]

EXPOSE 8080
