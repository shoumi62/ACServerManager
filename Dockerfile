FROM ubuntu:xenial

MAINTAINER pringlez <maintainer@pringlez>

ENV DEBIAN_FRONTEND=noninteractive

# Install System Updates & Packages
RUN groupadd -r gsa && useradd -r -d /home/gsa -g gsa gsa
RUN apt-get update \
    && apt-get install -y curl \
    && apt-get install -y lib32gcc1 \
    && apt-get install -y python-software-properties \
    && apt-get -y autoclean

# Args & Env Vars
ARG ACMANAGER_PORT=42555
ENV ACMANAGER_PORT=${ACMANAGER_PORT}
ARG ACSERVER_PORT_1=9600
ENV ACSERVER_PORT_1=${ACSERVER_PORT_1}
ARG ACSERVER_PORT_2=8081
ENV ACSERVER_PORT_2=${ACSERVER_PORT_2}
ARG STEAM_USERNAME=anonymous
ENV STEAM_USERNAME=${STEAM_USERNAME}
ARG STEAM_PASSWORD=
ENV STEAM_PASSWORD=${STEAM_PASSWORD}

# Install SteamCMD & AC Server Files
RUN mkdir -p /home/gsa/steamcmd /home/gsa/server /home/gsa/acmanager
RUN curl http://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar -C /home/gsa/steamcmd -xzf-
RUN /home/gsa/steamcmd/steamcmd.sh +@sSteamCmdForcePlatformType windows +login ${STEAM_USERNAME} ${STEAM_PASSWORD} +force_install_dir /home/gsa/server +app_update 302550 +quit
RUN rm -f /home/gsa/Steam/logs/*

#RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install NVM, NodeJS, NPM & PM2
RUN apt-get install python-software-properties
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install nodejs
RUN npm install pm2 -g

# Install ACManager Files & Dependencies
WORKDIR /home/gsa/acmanager
COPY . /home/gsa/acmanager
RUN npm install
RUN ./generate-frontend-content.sh
RUN chmod -R 775 /home/gsa
RUN chown -R gsa:gsa /home/gsa

# Volumes & Ports
VOLUME /home/gsa/acmanager
EXPOSE ${ACMANAGER_PORT}
EXPOSE ${ACSERVER_PORT_1}
EXPOSE ${ACSERVER_PORT_2}

# Once container starts run the ACServerManager
USER gsa
CMD ["pm2-runtime", "server.js"]
