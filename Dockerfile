FROM ubuntu:20.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      wget \
      curl \
      git \
      python \
      python3 \
      python3-pip \
      python3-ujson \
      python3-xlib \
      xvfb \
      imagemagick \
      zlib1g-dev \
      libjpeg-dev \
      psmisc \
      dbus-x11 \
      kmod \
      ffmpeg \
      sudo \
      net-tools \
      tcpdump \
      traceroute \
      bind9utils \
      libnss3-tools \
      iproute2 \
      software-properties-common && \
    apt-get clean

# Node setup
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

# Browser repos
RUN wget -q -O - https://www.webpagetest.org/keys/google/linux_signing_key.pub | apt-key add - && \
    sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
    add-apt-repository -y ppa:ubuntu-mozilla-daily/ppa && \
    add-apt-repository -y ppa:mozillateam/ppa

# Install browsers
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq \
      google-chrome-stable \
      google-chrome-beta \
      google-chrome-unstable \
      firefox \
      firefox-trunk \
      firefox-esr \
      firefox-geckodriver && \
    apt-get clean

# Get fonts
RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install ttf-mscorefonts-installer fonts-noto* && \
    fc-cache -f -v && \
    apt-get clean

# Install lighthouse
RUN apt-get install -y nodejs && \
    apt-get clean && \
    npm install -g lighthouse && \
    npm update -g

# Install other utilities
RUN pip3 install \
    dnspython \
    monotonic \
    pillow \
    psutil \
    requests \
    tornado \
    wsaccel \
    xvfbwrapper \
    'fonttools>=3.44.0,<4.0.0' \
    marionette_driver \
    selenium \
    future

COPY wptagent.py /wptagent/wptagent.py
COPY internal /wptagent/internal
COPY ws4py /wptagent/ws4py
COPY docker/linux-headless/entrypoint.sh /wptagent/entrypoint.sh

WORKDIR /wptagent

CMD ["/bin/bash", "/wptagent/entrypoint.sh"]
