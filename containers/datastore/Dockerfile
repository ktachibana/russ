FROM busybox:latest

VOLUME /russ/log
VOLUME /var/lib/postgresql/data
VOLUME /var/log/nginx

WORKDIR /volumes
RUN ln -s /russ/log russ-log
RUN ln -s /var/lib/postgresql/data db
RUN ln -s /var/log/nginx nginx-log
