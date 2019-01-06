# A Docker container for linux development on Windows
I've recently had a situation where I need to do some node development on a
Windows desktop, but on projects where several of the scripts set up for the
project rely on Linux.  I'd like to run my IDE + Browser on the Windows
machine and the node stuff in a Docker container.  You probably want to map a [volume](https://docs.docker.com/storage/volumes/) to `/root` so you can keep your files separate from the container itself.

This container exposes VNC and WebDAV **without authentication**.  Do *not*
expose the ports outside your local machine.  Ie. expose ports like this:
```
docker run -it --name linuxdev -p 127.0.0.1:5900:5900 -p 127.0.0.1:5000:80 -v linuxdev:/root jorupp/node-dev:v4
```

SSHD is enabled, but you need to set a password first via VNC with the `passwd` command.

## Ways to use this

### Recommended: VNC to run editor and commands
VNC is set up on port 5900 of the container (and a web server that provides an in-browser client on port 80).  Just connect and do whatever you want.  

Pros:
* **simple**.  Pretty much everything you'd expect from a Linux system will work.

Cons: 
* All the commands and tools you want to use must be done in the container.  Really nothing from your host is used, except the browser.
* I can't figure out how to get dynamic-resolution or multiple monitors working via VNC.

### OK option: SFTP + vscode "remote workspace" extension to edit from host and use VNC to run commands
Connect to the container via VNC and set a root password.  On your host, install VS Code and the "Remote Workspace" extension (https://marketplace.visualstudio.com/items?itemName=mkloubert.vscode-remote-workspace).  Create a new workspace (ie. `container.code-workspace`):
```
{
    "folders": [
        {
            "uri": "sftp://root:my_custon_password@localhost:2222/root/myapp",
            "name": "sftp"
        }
    ]
}
```

Pros:
* Uses the VS Code instance from your host, with all it's multi-monitor, resizing/etc. functionality.

Cons:
* Requires the "remote workspace" extension.  Basic VS Code functionality seems to work, but intellisense and the like don't appear to.  Neither does git integration

### Kinda works: Map folder with WebDAV to use any editor on the host and VNC to run commands
Map a network drive to http://localhost:5000/root/share (or whatever port you exposed 80 from the container as), and put your files in /root/share in the container.  Just make sure security on the files are set up so that www-data can access them (probably best to just make that user owner of your directory).

Pros:
* You can use any editor/tools on the host machine, since the OS is aware of the mapping.

Cons:
* dot-files (ie. .git and .gitignore) don't show up in the host.  This will cause some issues with GIT integration (since it won't think anything is ignored), and seems to cause some issues with VS Code resolving image imports.
* The WebDAV extensions are from Debian unstable (and the rest of the container is from Ubuntu Bionic) - not sure if there are some long-term or reliability issues here.

### Doesn't work well: Docker for Windows mount host directory
Docker for Windows supports mounting a directory from the host into the container: https://rominirani.com/docker-on-windows-mounting-host-directories-d96f3f056a2c.  This works ok, but you give up some development niceties.

Pros:
* Can use any tools on your host machine you want (since the files are really there)
* Data files aren't stored in the container, so you can use any existing management/backup tools you want.

Cons:
* Filewatchers in the container don't detect changes outside (ie. a typical dev service that watches for changes and reloads/restarts automatically).
* Performance is much lower for `node_modules`, especially if you have an on-access file scanner of some kind (like some anti-virus products).

## What's in this container

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
 * SSHD is enabled
 * Default VNC resolution to 1920x1080@24bpp
