# Native dependency refresh (2026-09-19)

The deployment images copy only `/usr/bin/stash` from the application image.
Updating that image does not update the wrapper's native libraries.

All variants build checksum-verified libheif 1.23.4 and libvips 8.18.6 against
their own distribution's codec dependencies. The scripts in `ci/` match the
Stash fork's `docker/native/` scripts. Update their release and checksum together.
The final image replaces the distro shared libraries and modules and checks
both loaded versions. HEIF codec plugins are built in; older external libheif
plugins are not loaded. The package database still describes the distro package,
so verify the replacement using `heif-info --version` and `vips --version`.

Alpine variants use Alpine 3.24 and upgrade its installed packages. The hardware
variant uses drivers from that release rather than mixing in edge packages.
The Debian variant uses Python 3.14 on trixie, upgrades system packages, and
installs Jellyfin FFmpeg 8. All variants provide `avifenc` for Stash's HDR preview
image generation.

The Alpine hardware variant keeps the distribution's Jellyfin FFmpeg 7.1.3;
the Debian hardware variant supplies Jellyfin FFmpeg 8.1.2. Other native
libraries follow each distribution's supported package versions.

Build with `--pull` to include current base-image and distro security updates.
Verify HEIC and AVIF encode/decode round trips through libvips in the final image,
and check FFmpeg/ffprobe and `avifenc --version`. Publishing and restarting a
running service are separate from building these changes locally.

All three amd64 variants were built locally and passed HEIC/AVIF round trips
with libheif 1.23.4 and libvips 8.18.6. FFmpeg/ffprobe and avifenc were checked.
GPU execution and other architectures were not tested. No image was published
and no running service was restarted.
