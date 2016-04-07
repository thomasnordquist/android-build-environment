# Android Dockerfile

FROM ubuntu:14.04

MAINTAINER Mobile Builds Eng "mobile-builds-eng@uber.com"

# Sets language to UTF8 : this works in pretty much all cases
ENV LANG en_US.UTF-8
RUN locale-gen $LANG

ENV DOCKER_ANDROID_LANG en_US
ENV DOCKER_ANDROID_DISPLAY_NAME mobileci-docker

# Never ask for confirmations
ENV DEBIAN_FRONTEND noninteractive

# Update apt-get
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get update
RUN apt-get dist-upgrade -y

# Installing packages
RUN apt-get -y install software-properties-common
RUN apt-get -y install bzip2 unzip openssh-client git curl zip wget
RUN apt-get -y install lib32stdc++6 lib32z1 lib32ncurses5 lib32bz2-1.0 --no-install-recommends
RUN apt-get -y install libxslt-dev libxml2-dev
RUN apt-get -y install build-essential

# Update apt
RUN apt-add-repository ppa:openjdk-r/ppa
RUN apt-get update

# Install Java
RUN apt-get -y install openjdk-8-jdk

# Install android sdk
RUN wget https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
RUN tar -xvzf android-sdk_r24.4.1-linux.tgz
RUN mv android-sdk-linux /usr/local/android-sdk
RUN rm android-sdk_r24.4.1-linux.tgz

ENV ANDROID_COMPONENTS tools,platform-tools,android-23,build-tools-23.0.2

# Install Android tools
RUN ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | /usr/local/android-sdk/tools/android update sdk --filter "${ANDROID_COMPONENTS}" --no-ui -a

# Install Android NDK
RUN wget https://dl.google.com/android/ndk/android-ndk-r9d-linux-x86_64.tar.bz2
RUN tar -xvjf android-ndk-r9d-linux-x86_64.tar.bz2
RUN mv android-ndk-r9d /usr/local/android-ndk
RUN rm android-ndk-r9d-linux-x86_64.tar.bz2

# Environment variables
ENV ANDROID_HOME /usr/local/android-sdk
ENV ANDROID_SDK_HOME $ANDROID_HOME
ENV ANDROID_NDK_HOME /usr/local/android-ndk
ENV PATH $PATH:$ANDROID_SDK_HOME/tools
ENV PATH $PATH:$ANDROID_SDK_HOME/platform-tools
ENV PATH $PATH:$ANDROID_NDK_HOME

# Export JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

# Support Gradle
ENV TERM dumb
ENV JAVA_OPTS "-Xms512m -Xmx1024m"

# Cleaning
RUN apt-get clean

# Fix permissions
RUN chown -R root:root $ANDROID_HOME $ANDROID_SDK_HOME $ANDROID_NDK_HOME
RUN chmod -R a+rx $ANDROID_HOME $ANDROID_SDK_HOME $ANDROID_NDK_HOME

# Creating project directories prepared for build when running
# `docker run`
ENV PROJECT /project
RUN mkdir $PROJECT
WORKDIR $PROJECT

RUN echo "sdk.dir=$ANDROID_HOME" > local.properties