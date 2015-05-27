FROM russ/base

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install cron
RUN bundle exec whenever --write-crontab

CMD /usr/sbin/cron -f
