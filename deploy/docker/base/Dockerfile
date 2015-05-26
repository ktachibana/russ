FROM debian:wheezy

RUN apt-get update; apt-get upgrade
ADD packages /
RUN DEBIAN_FRONTEND=noninteractive xargs apt-get -y install < packages

RUN git clone https://github.com/sstephenson/ruby-build.git --depth 1; cd ruby-build; ./install.sh

RUN ruby-build 2.2.2 /usr/local

RUN git clone https://github.com/ktachibana/russ.git --depth 1
WORKDIR russ
RUN gem install bundler; bundle install --without test develop
ENV RAILS_ENV=production
