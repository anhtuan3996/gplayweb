FROM ubuntu:18.04
MAINTAINER Francois-Xavier Aguessy <fxaguessy@users.noreply.github.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:guardianproject/ppa
RUN apt-get update && apt-get install -y \
	fdroidserver \
	git \
	lib32stdc++6 \
	lib32gcc1 \
	lib32z1 \
	lib32ncurses5 \
	libffi-dev \
	libssl-dev \
	libjpeg-dev \
	python-dev \
	python3 \
	python3-pip \
	openjdk-8-jdk \
	virtualenv \
	wget \
	zlib1g-dev

# Install Android SDK and build tools 22
WORKDIR /opt/
RUN wget https://dl.google.com/android/android-sdk_r24.3.4-linux.tgz \
    && echo "fb293d7bca42e05580be56b1adc22055d46603dd  android-sdk_r24.3.4-linux.tgz" | sha1sum -c \
    && tar xzf android-sdk_r24.3.4-linux.tgz \
    && rm android-sdk_r24.3.4-linux.tgz

ENV ANDROID_HOME=/opt/android-sdk-linux
ENV PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
RUN yes | android update sdk --no-ui -a --filter platform-tools,build-tools-22.0.1,android-22

RUN mkdir -p /data/fdroid/repo
RUN mkdir -p /etc/gplaycli

# Install gplayweb
ADD . /opt/gplayweb
WORKDIR /opt/gplayweb
RUN pip3 install -r requirements.txt

COPY ./gplayweb.conf.example /etc/gplayweb/gplayweb.conf
RUN cp /usr/local/lib/python3.6/dist-packages/root/.config/gplaycli/gplaycli.conf /etc/gplaycli/gplaycli.conf

VOLUME /data/fdroid
WORKDIR /data/fdroid
CMD /opt/gplayweb/gplayweb
