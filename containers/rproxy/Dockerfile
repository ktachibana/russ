FROM nginx:1.10

RUN apt-get update -qq && apt-get -y install \
  gettext \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY ./public /public
RUN ls -l /public
COPY ./containers/rproxy/nginx.conf.tmpl /etc/nginx/conf.d/

EXPOSE 443 80
CMD ["/bin/bash", "-c", "envsubst '$SERVER_NAME $CERT_DIR' < /etc/nginx/conf.d/nginx.conf.tmpl > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]
