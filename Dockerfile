FROM debian:10.10

RUN \
  DEBIAN_FRONTEND=noninteractive apt-get update -y && \
  DEBIAN_FRONTEND=noninteractive apt-get install gnupg2 wget lsb-release git -y && \
  wget -O - https://files.freeswitch.org/repo/deb/debian-release/fsstretch-archive-keyring.asc | apt-key add - && \
  echo "deb http://files.freeswitch.org/repo/deb/debian-release/ `lsb_release -sc` main" > /etc/apt/sources.list.d/freeswitch.list && \
  echo "deb-src http://files.freeswitch.org/repo/deb/debian-release/ `lsb_release -sc` main" >> /etc/apt/sources.list.d/freeswitch.list && \
  DEBIAN_FRONTEND=noninteractive apt-get clean -y && \
  DEBIAN_FRONTEND=noninteractive apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/*

RUN \
  DEBIAN_FRONTEND=noninteractive apt-get update -y && \
  DEBIAN_FRONTEND=noninteractive apt-get build-dep freeswitch -y && \
  DEBIAN_FRONTEND=noninteractive apt-get clean -y && \
  DEBIAN_FRONTEND=noninteractive apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/freeswitch
ADD . .

RUN ./bootstrap.sh

RUN mv modules.conf .modules.conf
COPY config/modules.conf modules.conf

RUN \
  ./configure \
  --exec-prefix="/usr/local/freeswitch" \
  --prefix="" \
  --enable-fhs

RUN make
RUN make install

WORKDIR /usr/local
RUN groupadd freeswitch
RUN \
  adduser \
  --quiet \
  --system \
  --home /usr/local/freeswitch \
  --gecos "FreeSWITCH open source softswitch" \
  --ingroup freeswitch freeswitch \
  --disabled-password
RUN chown -R freeswitch:freeswitch /usr/local/freeswitch/
RUN chmod -R ug=rwX,o= /usr/local/freeswitch/
RUN chmod -R u=rwx,g=rx /usr/local/freeswitch/bin/*
