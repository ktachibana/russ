#!/bin/bash

sed s/WEBAPP_PORT_8080_TCP_PORT/$WEBAPP_PORT_8080_TCP_PORT/ < /russ.conf > /etc/nginx/conf.d/russ.conf

nginx -g 'daemon off;'
