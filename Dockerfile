FROM ubuntu:xenial

MAINTAINER John Walsh <pringlez@github.com>

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

# Args & Meta
ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/Pringlez/ACServerManager"

# Install NodeJS, NPM & PM2
RUN apt-get install python-software-properties
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install nodejs
RUN npm install pm2 -g

# Install ACManager Files & Dependencies
RUN mkdir -p /home/gsa/server /home/gsa/acmanager
WORKDIR /home/gsa/acmanager
COPY . /home/gsa/acmanager
RUN npm install
RUN ./generate-frontend-content.sh
RUN chmod -R 775 /home/gsa
RUN chown -R gsa:gsa /home/gsa

# Volumes & Ports
VOLUME /home/gsa/server
VOLUME /home/gsa/acmanager
EXPOSE ${ACMANAGER_PORT}
EXPOSE ${ACSERVER_PORT_1}
EXPOSE ${ACSERVER_PORT_2}

# Starts ACServerManager
USER gsa
CMD ["pm2-runtime", "server.js"]
