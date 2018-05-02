FROM ubuntu:xenial

MAINTAINER pringlez <maintainer@pringlez>

ENV DEBIAN_FRONTEND=noninteractive

CMD ["bash"]

# Install System Updates & Packages
RUN groupadd -r gsa && useradd -r -d /home/gsa -g gsa gsa
RUN apt-get update \
    && apt-get install -y curl \
    && apt-get install -y wget \
    && apt-get install -y unzip \
    && apt-get install -y lib32gcc1 \
    && apt-get -y autoclean

# Install SteamCMD & AC Server Files
RUN mkdir -p /home/gsa/steamcmd
RUN curl http://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar -C /home/gsa/steamcmd -xzf-
RUN mkdir /home/gsa/server /home/gsa/acmanager
RUN chown -R gsa:gsa /home/gsa
RUN /home/gsa/steamcmd/steamcmd.sh +@sSteamCmdForcePlatformType windows +login username password +force_install_dir /home/gsa/server +app_update 302550 +quit
RUN rm -f /home/gsa/Steam/logs/*

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install NVM, NodeJS, NPM & PM2
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 8.11.1

RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.2/install.sh | bash

RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN npm install pm2 -g
RUN pm2 startup upstart

# Install ACManager Files & Dependencies
USER gsa
WORKDIR /home/gsa/acmanager
RUN wget https://github.com/Pringlez/ACServerManager/archive/master.zip
RUN unzip master.zip; mv ACServerManager-master/* .; rm -R ACServerManager-master; rm master.zip
RUN npm install
RUN ./generate-frontend-content.sh

# Volumes & Ports
VOLUME /home/gsa/acmanager
EXPOSE ${ACMANAGER_PORT}
EXPOSE ${ACSERVER_PORT_1}
EXPOSE ${ACSERVER_PORT_2}

USER gsa
RUN pm2 start /home/gsa/acmanager/server.js
RUN pm2 save