FROM ruby:2.2

RUN apt-get update; apt-get upgrade -y

ADD . /russ
VOLUME /russ/log

WORKDIR /russ
ENV RAILS_ENV=production

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install libpq-dev
RUN bundle install --without test develop
