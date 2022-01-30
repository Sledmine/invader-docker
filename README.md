# invader-docker

Approach to use [Invader](https://github.com/SnowyMouse/invader) as cloud map building software,
also provides a Dockerfile for using it on any Linux distro.

# How to...
Be sure to have [Docker](https://www.docker.com) installed and follow the commands from below:
```
git clone https://github.com/Sledmine/invader-docker
docker build -t invader-docker ./invader-docker
```
After finishing building the image just map your folder volumes and run commands on it:
```bash
docker run \
-v /my/host/folder/data:/home/invader/data \
-v my/host/folder/tags:/home/invader/tags \
-v my/host/folder/maps:/home/invader/maps \
invader-docker \
invader-build -g gbx-custom -H "levels/test/bloodgulch/bloodgulch"
```

# Community!

Join the official [Invader Discord](https://discord.gg/RCX3nvw) server!

Take a look to our [Shadowmods Discord](https://discord.shadowmods.net) server, here we showcase and
give support with modding for Halo Custom Edition!

Other Halo related servers:

- [The Halo Archive](https://discord.gg/9MXmuPPbUG)
- [Halo Mods](https://discord.com/invite/WuurKwr)
- [MCC Project HUB](https://discord.com/invite/q4f7nTt)
- [Official Halo Discord Server](https://discord.com/invite/q4f7nTt)
- [Halo: CE Refined](https://discord.gg/QzSR2xNGzp)