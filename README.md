# A Docker container for linux development on Windows
I've recently had a situation where I need to do some node development on a
Windows desktop, but on projects where several of the scripts set up for the
project rely on Linux.  I'd like to run my IDE + Browser on the Windows
machine and the node stuff in a Docker container.

**Warning: there are some known issues with dot-files (ie. .git or .gitignore) - I think it's the nginx webdav extension causing it.  This can make some projects/IDEs act odd.**

This image is based on `dorowu/ubuntu-desktop-lxde-vnc`, and adds:
 * `git`
 * `screen`
 * `ssh`
 * `vim`
 * `node`
 * `yarn`
 * `vscode`
 * WebDav extensions for `nginx` (based on Debian Sid)
 * Nginx-webdav sharing of `/root/share`
 * Default VNC resolution to 1920x1080@24bpp

This container exposes VNC and WebDAV **without authentication**.  Do *not*
expose the ports outside your local machine.  Ie. expose ports like this:
```
docker run -it --name linuxdev -p 127.0.0.1:5900:5900 -p 127.0.0.1:5000:80 jorupp/node-dev:v3
```
