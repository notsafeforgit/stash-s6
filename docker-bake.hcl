// release CI
group "release_ci_alpine" {
  targets = ["alpine", "hwaccel-alpine"]
  output = ["type=registry"]
}

group "release_ci_debian" {
  targets = ["hwaccel"]
  output = ["type=registry"]
}

// Native previews use an explicitly selected source digest.
group "native_ci_alpine" {
  targets = ["alpine-native-preview", "hwaccel-alpine-native-preview"]
  output = ["type=registry"]
}

group "native_ci_debian" {
  targets = ["hwaccel-native-preview"]
  output = ["type=registry"]
}

// targets
group "default" {
  targets = ["alpine", "hwaccel-alpine", "hwaccel"]
}

// variables
variable "OWNER_NAME" {
  type = string
  default = "notsafeforgit"
}

variable "IMAGE_NAME" {
  type = string
  default = "stash-s6"
}

variable "CACHE_IMAGE_NAME" {
  type = string
  default = "${IMAGE_NAME}-cache"
}

variable "SHORT_BUILD_DATE" {
  type = string
  default = formatdate("YYYY-MM-DD", BUILD_DATE)
}

variable "BUILD_DATE" {
  type = string
  default = timestamp()
}

variable "GITHASH" {
  type = string
  default = "local-build"
}

variable "STASH_SOURCE" {
  type = string
  default = "ghcr.io/notsafeforgit/stash@sha256:0faad6d2cffb19dc97421b0879e638c83e4fe245eda871505c5d913d3fc44805"
}

variable "NATIVE_REVISION" {
  type = string
  default = "local-build"
}

variable "CI" {
  type = bool
  default = false
}

// common arguments
target "_common" {
  context = "."
  attest = [{
      type = "provenance"
      mode = "max"
  }, {
    type = "sbom"
  }]
  args = {
    BUILD_DATE = BUILD_DATE,
    SHORT_BUILD_DATE = SHORT_BUILD_DATE,
    GITHASH = CI ? GITHASH : "local-build"
  }
}

target "_alpine_multi" {
  platforms = ["linux/amd64", "linux/arm64", "linux/arm/v6", "linux/arm/v7"]
}

target "_debian_multi" {
  platforms = ["linux/amd64", "linux/arm64"]
}

target "_native" {
  platforms = ["linux/amd64"]
  pull = true
  no-cache-filter = ["stash"]
  args = {
    UPSTREAM_STASH = STASH_SOURCE
  }
  labels = {
    "io.stash.source.image" = STASH_SOURCE
  }
}

// targets
target "alpine" {
  inherits = ["_common", "_alpine_multi"]
  dockerfile = "dockerfile/alpine.Dockerfile"
  tags = tag("alpine")
  cache-to = cache_to("alpine")
  cache-from = cache_from("alpine")
}

target "hwaccel-alpine" {
  inherits = ["_common", "_alpine_multi"]
  dockerfile = "dockerfile/hwaccel-alpine.Dockerfile"
  tags = tag("hwaccel-alpine")
  cache-to = cache_to("hwaccel-alpine")
  cache-from = cache_from("hwaccel-alpine")
}

target "hwaccel" {
  inherits = ["_common", "_debian_multi"]
  dockerfile = "dockerfile/hwaccel.Dockerfile"
  tags = tag("hwaccel")
  cache-to = cache_to("hwaccel")
  cache-from = cache_from("hwaccel")
}

// Native archive development
target "alpine-native-preview" {
  inherits = ["alpine", "_native"]
  platforms = ["linux/amd64"]
  tags = native_tag("alpine-native-preview")
  cache-to = cache_to("alpine-native-preview")
  cache-from = cache_from("alpine-native-preview")
}

target "hwaccel-alpine-native-preview" {
  inherits = ["hwaccel-alpine", "_native"]
  platforms = ["linux/amd64"]
  tags = native_tag("hwaccel-alpine-native-preview")
  cache-to = cache_to("hwaccel-alpine-native-preview")
  cache-from = cache_from("hwaccel-alpine-native-preview")
}

target "hwaccel-native-preview" {
  inherits = ["hwaccel", "_native"]
  platforms = ["linux/amd64"]
  tags = native_tag("hwaccel-native-preview")
  cache-to = cache_to("hwaccel-native-preview")
  cache-from = cache_from("hwaccel-native-preview")
}

# local test
target "local-test" {
  context = "."
  dockerfile = "dockerfile/alpine.Dockerfile"
   args = {
    BUILD_DATE = BUILD_DATE,
    SHORT_BUILD_DATE = SHORT_BUILD_DATE,
    GITHASH = "local-build"
  }
  tags = ["stash-s6:local-test"]
  cache-to = cache_to("alpine")
  cache-from = cache_from("alpine")
}

function "cache_from" {
  params = [variant]
  result = [{
    type = "registry",
    ref = "ghcr.io/${OWNER_NAME}/${CACHE_IMAGE_NAME}:cache-${variant}"
  }, {
    type = "registry",
    ref = "ghcr.io/${OWNER_NAME}/${IMAGE_NAME}:${variant}"
  }]
}

function "cache_to" {
  params = [variant]
  result = CI ? [{
    type = "registry",
    ref = "ghcr.io/${OWNER_NAME}/${CACHE_IMAGE_NAME}:cache-${variant}",
    mode = "max",
    compression = "zstd"
  }] : []
}

// functions
function "tag" {
  params = [variant]
  result = concat(
    [
      "ghcr.io/${OWNER_NAME}/${IMAGE_NAME}:${variant}",
      "ghcr.io/${OWNER_NAME}/${IMAGE_NAME}:${variant}-${SHORT_BUILD_DATE}"
    ],
    variant == "alpine" ? [
      "ghcr.io/${OWNER_NAME}/${IMAGE_NAME}:latest"
    ] : []
  )
}

function "native_tag" {
  params = [variant]
  result = [
    "ghcr.io/${OWNER_NAME}/${IMAGE_NAME}:${variant}",
    "ghcr.io/${OWNER_NAME}/${IMAGE_NAME}:${variant}-${NATIVE_REVISION}"
  ]
}
