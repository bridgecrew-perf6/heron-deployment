# build environment
FROM node:alpine as build

# Build admin-app production
# WORKDIR /app/admin-prod
# COPY ./heron-admin/package.json .
# RUN yarn

# COPY ./heron-admin .

# ARG REACT_APP_BASE_URL

# RUN echo $REACT_APP_BASE_URL

# ENV REACT_APP_BASE_URL $REACT_APP_BASE_URL

# RUN yarn build

# Build admin-app testing
WORKDIR /app/admin-testing

COPY ./heron-admin/package.json .
RUN yarn

COPY ./heron-admin .

ARG REACT_APP_BASE_URL_TESING

RUN echo $REACT_APP_BASE_URL_TESING

ENV REACT_APP_BASE_URL $REACT_APP_BASE_URL_TESING

RUN yarn build
WORKDIR /app/nginx_config
# MODE: Testing
COPY ./heron.api.dev.conf .
COPY ./heron.interface.dev.conf .
# MODE: Production
COPY ./heron.admin.conf .
COPY ./heron.interface.conf .
COPY ./heron.api.conf .

# production environment
FROM nginx:stable-alpine

# COPY --from=build /app/admin-prod/build /srv/www/admin-cleverbooking.prod
COPY --from=build /app/admin-testing/build /srv/www/test-admin-cleverbooking.prod

COPY --from=build /app/nginx_config/heron.admin.conf /etc/nginx/conf.d/heron.admin.conf

COPY --from=build /app/nginx_config/heron.api.conf /etc/nginx/conf.d/heron.api.conf

COPY --from=build /app/nginx_config/heron.interface.conf /etc/nginx/conf.d/heron.interface.conf

# MODE: TEST
COPY --from=build /app/nginx_config/heron.api.dev.conf /etc/nginx/conf.d/heron.api.dev.conf
COPY --from=build /app/nginx_config/heron.interface.dev.conf /etc/nginx/conf.d/heron.interface.dev.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]