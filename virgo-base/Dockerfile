FROM openjdk:8-jdk-slim-stretch

LABEL maintainer "Aiur Tech <cto+docker@aiurtech.co.uk>"

ARG VIRGO_DIST_VERSION=0.6.2
ENV VIRGO_VERSION ${VIRGO_DIST_VERSION}
ENV HADOOP_VERSION 2.7.7
ENV HIVE_VERSION 1.2.2
ENV SPARK_VERSION=2.2.3
ENV VIRGO_HOME=/opt/virgo

RUN apt-get update \
&& apt-get install --no-install-recommends --no-install-suggests -y vim netcat curl \
&& rm -rf /var/lib/apt/lists/*

COPY virgo-utils.sh $VIRGO_HOME/virgo-utils.sh
COPY coordinator.sh $VIRGO_HOME/coordinator.sh

WORKDIR ${VIRGO_HOME}