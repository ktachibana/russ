FROM ruby:2.3

RUN apt-get update -qq && apt-get -y install \
  libpq-dev \
  cron \
  nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /russ
COPY Gemfile Gemfile.lock .ruby-version /russ/
RUN bundle install --without test development

COPY . /russ

ENV RAILS_ENV=production

RUN bundle install --without test development

ENTRYPOINT ["bundle", "exec"]
EXPOSE 8080
