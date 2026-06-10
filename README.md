# stashapp/stash with(out) s6
![](docs/icon/horiz-bg.svg)
for [stashapp/stash#4300](https://github.com/stashapp/stash/issues/4300)
- non-root user support
  - PUID/ PGID switching support
- TZ settings
- CUDA/ QSV images
  - NVENC encoding session patches
- automatic python dependency installs

-----
# Tags

## `latest` / `alpine` ![Docker Image Size (tag)](https://img.shields.io/docker/image-size/feederbox826/stash-s6/alpine)

```
ghcr.io/feederbox826/stash-s6:alpine
```
no hardware acceleration, built on alpine linux
## `hwaccel` ![Image size](https://img.shields.io/docker/image-size/feederbox826/stash-s6/hwaccel)

```
ghcr.io/feederbox826/stash-s6:hwaccel
```
hardware acceleration from [jellyfin-ffmpeg](https://jellyfin.org/docs/general/administration/hardware-acceleration/), built on debian. (Scheduled to be replaced with v0.29.0 [#46](https://github.com/feederbox826/stash-s6/issues/46))

## `hwaccel-alpine` ![Image size](https://img.shields.io/docker/image-size/feederbox826/stash-s6/hwaccel-alpine)

```
ghcr.io/feederbox826/stash-s6:hwaccel-alpine
```
hardware acceleration from [jellyfin-ffmpeg](https://jellyfin.org/docs/general/administration/hardware-acceleration/), built on alpine

## v3 rewrite variants

These fork images are built from `ghcr.io/notsafeforgit/stash:v3-rewrite`:
- `v3-rewrite` / `alpine-v3-rewrite`
- `hwaccel-v3-rewrite`
- `hwaccel-alpine-v3-rewrite`

## environment variables
`PUID` - Process User ID  
`PGID` - Process Group ID  
`AVGID` - Additional Group ID (usually for QSV)  

`AUTO_AVGID` - allow automatic AVGID detection and replacement  
`TZ` - timezone  
`CUSTOM_CERT_PATH` - Path to custom root certificates to be added to stash (defaults to `/config/certs`)  
`INSTALL_PY_DEPS` - Automatically install some python build-tools at startup  
`IGNORE_BAD_PERMS` - Allow continuing with bad permissions instead of exiting.  
`STASH_ENABLE_V3_UI` - Set to `true` to enable the forked v3 Stash UI.

## migration-specific environment variables
`MIGRATE` - automatic migration from `stashapp/stash` or `hotio/stash`

## Run modes
### `stashapp/stash compatibility`
I want to keep using the `stashapp/stash` image or possibly switch back
- Replace `image: stashapp/stash` with your desired image
- You will see a message `Running in stashapp/stash compatibility mode...`

# docs
- migrate from `stashapp/stash` or `hotio/stash`: [docs/migrate](docs/migrate.md)
- hardware acceleration: [docs/hwaccel](docs/hwaccel/)
  - Intel (QSV): [docs/hwaccel/intel](docs/hwaccel/intel.md)
  - NVIDIA (CUDA): [docs/hwaccel/nvidia](docs/hwaccel/nvidia.md)
- advanced
  - docker `read_only`: [docs/advanced/read_only](docs/advanced/read_only.md)
  - rootless docker: [docs/advanced/rootless](docs/advanced/rootless.md)
  - `uv-py`: [docs/advanced/uv-py](docs/advanced/uv-py.md)
