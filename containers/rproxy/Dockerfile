FROM nginx:1.10

RUN apt-get update -qq && apt-get -y install \
  gettext \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY ./public /public
COPY ./containers/rproxy/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 443 80
CMD ["nginx", "-g", "daemon off;"]
