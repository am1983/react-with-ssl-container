FROM node:alpine AS build
WORKDIR /app
COPY ./package.json .
RUN npm install
COPY . .
RUN npm run build

FROM httpd AS serve
COPY --from=build /app/build/ /usr/local/apache2/htdocs/
COPY container.crt container.key /usr/local/apache2/conf/
COPY httpd.conf /usr/local/apache2/conf/
COPY httpd-ssl.conf /usr/local/apache2/conf/extra/
EXPOSE 443