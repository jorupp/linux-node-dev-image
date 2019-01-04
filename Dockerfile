FROM dorowu/ubuntu-desktop-lxde-vnc

RUN apt-get update && apt-get install -y \
	git \
	gnupg \
	screen \
	ssh \
	vim \
	&& sh -c 'curl -sL https://deb.nodesource.com/setup_11.x | bash -' \
	&& apt-get install -y nodejs \
	&& npm install -g yarn \
	&& curl -L https://go.microsoft.com/fwlink/?LinkID=760868 -o vscode.deb \
	&& apt install -y ./vscode.deb \
	&& rm vscode.deb \
	&& rm -rf /var/lib/apt/lists/*

# /usr/local/bin/xvfb.sh has the line for the resolution to use
#    the default of the base image is 1024x768x16
#    something like 1920x1080x24 should work nicely (but RESOLUTION environmental variable can override it)
RUN sed -i "s/1024x768x16/1920x1080x24/" /usr/local/bin/xvfb.sh \
	&& sed -i "s/1024x768/1920x1080/" /startup.sh

# browser is on port 80, VNC on port 5900

# mapping /root/.ssh to a volume with your SSH key in id_rsa will allow it to be used automatically

LABEL maintainer="jorupp@gmail.com"

EXPOSE 5900
