FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
	curl \
	git \
	gnupg \
	libreadline7 \
	net-tools \
	screen \
	ssh \
	vim \
	&& sh -c 'curl -sL https://deb.nodesource.com/setup_11.x | bash -' \
	&& apt-get install -y nodejs \
	&& npm install -g yarn \
	&& rm -rf /var/lib/apt/lists/*

LABEL maintainer="jorupp@gmail.com"

EXPOSE 10012
