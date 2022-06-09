# build environment
FROM node:alpine as build

WORKDIR /app

COPY ./heron-admin/package.json .
RUN yarn

COPY ./heron-admin .

ARG REACT_APP_BASE_URL

RUN echo $REACT_APP_BASE_URL

ENV REACT_APP_BASE_URL $REACT_APP_BASE_URL

RUN yarn build

COPY ./heron.admin.conf .
COPY ./heron.interface.conf .
COPY ./heron.api.conf .

# production environment
FROM nginx:stable-alpine

COPY --from=build /app/build /srv/www/heron.admin.com

COPY --from=build /app/heron.admin.conf /etc/nginx/conf.d/heron.admin.conf

COPY --from=build /app/heron.api.conf /etc/nginx/conf.d/heron.api.conf

COPY --from=build /app/heron.interface.conf /etc/nginx/conf.d/heron.interface.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]