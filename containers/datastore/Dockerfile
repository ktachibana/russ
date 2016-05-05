FROM busybox:latest

VOLUME /russ/log
VOLUME /var/lib/postgresql/data

WORKDIR /volumes
RUN ln -s /russ/log russ-log
RUN ln -s /var/lib/postgresql/data db
