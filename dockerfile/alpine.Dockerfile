# syntax=docker/dockerfile:1
ARG \
  STASH_TAG="v3-rewrite" \
  UPSTREAM_STASH="ghcr.io/notsafeforgit/stash:${STASH_TAG}"
FROM $UPSTREAM_STASH AS stash

# Build patched HEIF/AVIF support against the runtime distribution.
FROM alpine:3.24 AS heif
RUN apk add --no-cache build-base cmake pkgconf curl ca-certificates aom-dev dav1d-dev libde265-dev x265-dev libjpeg-turbo-dev libpng-dev
RUN apk add --no-cache meson samurai xz glib-dev expat-dev libwebp-dev tiff-dev librsvg-dev pango-dev fontconfig-dev lcms2-dev fftw-dev libexif-dev orc-dev openjpeg-dev libjxl-dev poppler-dev cfitsio-dev libimagequant-dev highway-dev libarchive-dev openexr-dev cgif-dev imagemagick-dev
COPY ci/build-libheif.sh /build-libheif.sh
COPY ci/build-vips.sh /build-vips.sh
RUN sh /build-libheif.sh && sh /build-vips.sh

FROM alpine:3.24 AS avif
RUN apk add --no-cache build-base cmake git pkgconf curl ca-certificates aom-dev dav1d-dev libjpeg-turbo-dev libpng-dev libxml2-dev libyuv libyuv-dev
COPY ci/build-libavif.sh /build-libavif.sh
RUN sh /build-libavif.sh

FROM docker.io/library/alpine:3.24 AS final
# OS environment variables
ENV HOME="/config" \
  TZ="Etc/UTC" \
  USER="stash" \
  STASH_CONFIG_FILE="/config/config.yml" \
  # python env
  UV_TARGET="/pip-install/install" \
  PYTHONPATH="/pip-install/install" \
  UV_CACHE_DIR="/pip-install/cache" \
  UV_BREAK_SYSTEM_PACKAGES=1 \
  # hardware acceleration env
  HWACCEL="NONE" \
  # Logging
  LOGGER_LEVEL="1"
COPY --from=stash --chmod=755 /usr/bin/stash /app/stash
COPY --from=ghcr.io/feederbox826/dropprs:latest /dropprs /usr/bin/dropprs
RUN \
  echo "**** install base packages ****" && \
  apk upgrade --no-cache && \
  apk add --no-cache --no-progress \
    bash \
    curl \
    python3 \
    nano \
    shadow \
    wget \
    yq-go
RUN \
  echo "**** install packages ****" && \
  apk add --no-cache --no-progress \
    ca-certificates \
    ffmpeg \
    tzdata \
    uv \
    vips-tools \
    vips-heif vips-jxl vips-magick vips-poppler \
    libavif-apps libxml2 libyuv \
    aom-libs libdav1d libde265 x265-libs libjpeg-turbo libpng
RUN \
  echo "**** symlink uv-pip ****" && \
  ln -s \
    /usr/bin/uv-pip \
    /usr/bin/pip && \
  ln -s \
    /usr/bin/uv-pip \
    /opt/uv-pip && \
  ln -s \
    /usr/bin/uv-py \
    /opt/uv-py && \
  echo "**** create stash user and make our folders ****" && \
  groupadd -g 911 stash && \
  useradd -u 911 -d /config -s /bin/bash -r -g stash stash && \
  chage -d 0 stash && \
  mkdir -p \
    /config \
    /defaults

# Replace distro libraries and modules with the matching security builds.
RUN find /usr/lib \( -name 'libheif.so*' -o -name 'libvips.so*' -o -name 'libvips-cpp.so*' \) -delete \
    && rm -rf /usr/lib/vips-modules-* /usr/lib/*-linux-gnu/vips-modules-*
COPY --from=heif /out/ /
COPY --from=avif /out/ /
RUN heif-info --version | grep -F '1.23.4' \
    && vips --version | grep -F '8.18.6' \
    && avifenc --version | grep -F '1.4.2'

COPY stash/root/ /
VOLUME /pip-install

# dynamic labels
ARG \
  BUILD_DATE \
  SHORT_BUILD_DATE \
  GITHASH \
  OFFICIAL_BUILD="false"
ENV \
  STASH_S6_VARIANT="alpine" \
  STASH_S6_BUILD_DATE=$SHORT_BUILD_DATE \
  STASH_S6_GITHASH=$GITHASH \
  STASH_HW_TEST_TIMEOUT=0
LABEL \
  org.opencontainers.image.created=$BUILD_DATE \
  org.opencontainers.image.revision=$GITHASH \
  org.opencontainers.image.description="stashapp/stash container with hwaccel, py and user switching" \
  org.opencontainers.image.source=https://github.com/notsafeforgit/stash-s6 \
  org.opencontainers.image.vendor=notsafeforgit \
  org.opencontainers.image.licenses=AGPL-3.0-only
WORKDIR /config
EXPOSE 9999
HEALTHCHECK --start-period=30s CMD curl -sf http://localhost:${STASH_PORT:-9999}/healthz
CMD ["/bin/bash", "/opt/entrypoint.sh"]
