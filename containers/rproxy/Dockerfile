FROM node:10-alpine AS build-env

COPY . /work
WORKDIR /work
RUN yarn install


FROM nginx:1.10

COPY --from=build-env /work/public /public
COPY ./containers/rproxy/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 443 80
CMD ["nginx", "-g", "daemon off;"]
