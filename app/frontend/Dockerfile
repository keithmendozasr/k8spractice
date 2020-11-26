FROM node:12-alpine AS build

WORKDIR /project
COPY package.json package-lock.json ./
COPY public public/
COPY src src/
RUN npm ci
RUN npm run build

FROM httpd:2.4-alpine
COPY --from=build /project/build /usr/local/apache2/htdocs
COPY apache_httpd.conf /usr/local/apache2/conf/httpd.conf
