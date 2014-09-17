FROM ubuntu:latest

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server git curl libmysqlclient-dev g++ make npm
RUN mkdir /var/run/sshd

RUN echo "root:root" | chpasswd

RUN git clone --depth=1 git://github.com/sstephenson/rbenv.git /usr/local/rbenv
RUN git clone --depth=1 git://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build
ADD rbenv.sh /etc/profile.d/rbenv.sh
ENV RBENV_ROOT /usr/local/rbenv
ENV PATH $RBENV_ROOT/shims:$RBENV_ROOT/bin:$PATH
RUN rbenv install 2.1.2
RUN rbenv global 2.1.2
RUN gem install bundler

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server
RUN (/usr/bin/mysqld_safe &); sleep 3; mysqladmin create russ; echo "GRANT ALL PRIVILEGES ON *.* TO russ@localhost IDENTIFIED BY 'russ';" | mysql -u root

RUN gem install god
RUN rbenv rehash
ADD god.conf /etc/god.conf
RUN mkdir -p /etc/god.d

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN useradd -m russ
RUN echo "russ:russ" | chpasswd
RUN chsh -s /bin/bash russ

RUN mkdir -p /u/apps/russ
RUN chown russ:russ /u/apps/russ

RUN touch /etc/god.d/russ.god
RUN chown russ:russ /etc/god.d/russ.god

RUN echo "russ ALL=(ALL) NOPASSWD: /usr/local/rbenv/shims/god" >> /etc/sudoers
RUN rbenv rehash

EXPOSE 22
CMD supervisord
