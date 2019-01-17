FROM node:6-slim

ARG PROXY_SERVER=http://your-server:your-port
ARG VIEW
ARG BROWSERIFY

ENV VIEW=${VIEW} BROWSERIFY=${BROWSERIFY}

ENV INSTALL_PATH /app
ENV PATH $INSTALL_PATH/node_modules/.bin:${PATH}

RUN if [ $PROXY_SERVER ]; then echo "Configuring with proxy server: ${PROXY_SERVER}"; else echo "Environment variable PROXY_SERVER must be set at build time. Exiting"; exit 1; fi
RUN echo "Configuring with view package: ${VIEW} (can be modified at runtime)"

# Install essentials
RUN apt-get update -qq && apt-get install -y build-essential

# Install node_modules with yarn.json
ADD package.json yarn.lock /tmp/
RUN cd /tmp && yarn install --frozen-lockfile
RUN mkdir -p $INSTALL_PATH && cd $INSTALL_PATH && cp -R /tmp/node_modules $INSTALL_PATH

WORKDIR $INSTALL_PATH

ADD . .

RUN sed -ie 's@http:\/\/your-server:your-port@'"$PROXY_SERVER"'@g' $INSTALL_PATH/gulp/config.js

EXPOSE 8003 3001

CMD [ "/bin/bash", "-c", "yarn start --view=${VIEW} ${BROWSERIFY:+--browserify}"]
