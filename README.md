# stashapp/stash with(out) s6
![](docs/icon/horiz-bg.svg)
for [stashapp/stash#4300](https://github.com/stashapp/stash/issues/4300)
- non-root user support
  - PUID/ PGID switching support
- TZ settings
- CUDA/ QSV images
  - NVENC encoding session patches
- optional installation of explicitly configured Python dependencies

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

## Compatible release and native previews

The final v2.5-compatible source is tagged `v2.5-compatible-final` in
[notsafeforgit/stash](https://github.com/notsafeforgit/stash/blob/v3-rewrite/docs/releases/v2.5-compatible-final.md).
Its preserved wrapper variants are `alpine-v2.5-compatible-final`,
`hwaccel-v2.5-compatible-final`, and `hwaccel-alpine-v2.5-compatible-final` in
`ghcr.io/notsafeforgit/stash-s6`. The release manifest records immutable digests.
Pin that release or a digest to remain on the compatible database format.

Native archive development publishes `alpine-native-preview`,
`hwaccel-native-preview`, and `hwaccel-alpine-native-preview`. These are separate
from the old `v3-rewrite` tags. Pushes validate the build definition; publishing
requires a manual dispatch and an explicit Stash image digest:

```sh
gh workflow run develop.yml --ref v3-rewrite -f stash_digest=sha256:FULL_STASH_IMAGE_DIGEST
```

The wrapper never selects the newest image automatically. Each native image
records its full source reference in `io.stash.source.image` and receives an
additional tag containing the wrapper revision and source digest prefix.
Test native releases against a copy before migrating a live database.

Native variants include Translate Shell for Stash's optional translation worker.
The executable does not enable translations by itself: configure
`translation_worker_enabled: true` in Stash and restart to process queued work.

## environment variables
`PUID` - Process User ID  
`PGID` - Process Group ID  
`AVGID` - Additional Group ID (usually for QSV)  

`AUTO_AVGID` - allow automatic AVGID detection and replacement  
`TZ` - timezone  
`CUSTOM_CERT_PATH` - Path to custom root certificates to be added to stash (defaults to `/config/certs`)  
`INSTALL_PYTHON_REQUIREMENTS` - Set to `true` to install the explicit `/config/requirements.txt` at startup; disabled by default.

`INSTALL_PY_DEPS` - Set to `true` to install optional Python build tools at startup.

`IGNORE_BAD_PERMS` - Allow continuing with bad permissions instead of exiting.  
Native Stash includes only the v3 UI; no UI opt-in variable is needed.

## Python dependencies

Native startup does not install a bundled scraper package set or search plugin
and scraper directories for requirements. Python remains available for chosen
extensions. Provision their dependencies in a derived image or the persistent
Python environment, or explicitly enable `INSTALL_PYTHON_REQUIREMENTS` with a
nonempty `/config/requirements.txt`. Pin versions in that file. The wrapper
preserves its contents and stops startup if an opted-in installation fails.
`INSTALL_PY_DEPS` is a separate opt-in for compiler/build tools.

## migration-specific environment variables
`MIGRATE` - automatic migration from `stashapp/stash` or `hotio/stash`

## Run modes
### Existing configuration layout

An existing `/root/.stash` mount can retain its location without `MIGRATE`.
This is a filesystem layout choice, not upstream database compatibility.
Native database upgrades are one-way; use the frozen compatible release to
stay on the older format. After native writes begin, returning to an upstream
image does not constitute a lossless rollback.

# docs
- migrate from `stashapp/stash` or `hotio/stash`: [docs/migrate](docs/migrate.md)
- hardware acceleration: [docs/hwaccel](docs/hwaccel/)
  - Intel (QSV): [docs/hwaccel/intel](docs/hwaccel/intel.md)
  - NVIDIA (CUDA): [docs/hwaccel/nvidia](docs/hwaccel/nvidia.md)
- advanced
  - docker `read_only`: [docs/advanced/read_only](docs/advanced/read_only.md)
  - rootless docker: [docs/advanced/rootless](docs/advanced/rootless.md)
  - `uv-py`: [docs/advanced/uv-py](docs/advanced/uv-py.md)
