FROM dorowu/ubuntu-desktop-lxde-vnc

# Install the tools we need
RUN apt-get update \
	&& apt-get install -y \
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

# turn on (but de-prioritize) Debian Sid (so we don't hide the normal packages)
# install the latest nginx + webdav extentions from sid (ubuntu bionic's version hangs when used from Windows 10)
RUN sh -c 'echo "Package: *\nPin: release o=Debian\nPin-Priority: 10\n\nPackage: nginx*\nPin: release o=Debian\nPin-Priority: 600" >> /etc/apt/preferences.d/pin-debian' \
	&& sh -c 'echo "deb http://deb.debian.org/debian sid main" >> /etc/apt/sources.list' \
	&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8B48AD6246925553 \
	&& apt-get update \
	&& apt-get install -t sid -y \
	libnginx-mod-http-dav-ext \
	nginx \
	&& rm -rf /var/lib/apt/lists/*

# /usr/local/bin/xvfb.sh has the line for the resolution to use
#    the default of the base image is 1024x768x16
#    something like 1920x1080x24 should work nicely (but RESOLUTION environmental variable can override it)
RUN sed -i "s/1024x768x16/1920x1080x24/" /usr/local/bin/xvfb.sh \
	&& sed -i "s/1024x768/1920x1080/" /startup.sh

# expose /root/share as http://*:80/share (via existing nginx site) with WebDAV
RUN sed -i "s#location @proxy#location /share { autoindex on; charset utf-8; dav_methods PUT DELETE MKCOL COPY MOVE; dav_ext_methods PROPFIND OPTIONS LOCK UNLOCK; dav_ext_lock zone=share; dav_access user:rw group:rw all:rw; root /root; set \$x \$uri\$request_method; if (\$x ~ [^/]MKCOL\$) { rewrite ^(.*)\$ \$1/; } }\n    location @proxy#" /etc/nginx/sites-enabled/default \
	&& sh -c 'echo "dav_ext_lock_zone zone=share:10m;" >> /etc/nginx/sites-enabled/default' \
	&& mkdir /root/share \
	&& chmod 777 /root/share

# set up SSHD (though you still have to set up a password for it to work)
RUN sh -c 'echo "[program:sshd]\ncommand=/usr/sbin/sshd -D" >> /etc/supervisor/conf.d/supervisord.conf' \
	&& sh -c 'echo "PermitRootLogin yes" >> /etc/ssh/sshd_config' \
	&& mkdir -p /var/run/sshd

# browser+WebDAV is on port 80, VNC on port 5900

# mapping /root/.ssh to a volume with your SSH key in id_rsa will allow it to be used automatically

LABEL maintainer="jorupp@gmail.com"

EXPOSE 5900
