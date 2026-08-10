#!/usr/bin/env bash
set -euo pipefail

: "${RUNNER_TEMP:?RUNNER_TEMP must be set}"
: "${GITHUB_PATH:?GITHUB_PATH must be set}"
: "${GITHUB_ENV:?GITHUB_ENV must be set}"

readonly ARK_VERSION="4.7.1"
readonly ARK_SHA256="3d9e46ac5a8ecb19c9e4e87391fc5a8bf7c582ad6cea9599c1976f843d662861"
readonly FAT_IMAGE="fatscript/fry@sha256:fa8bfe0d759ce4bd7146ce9c97521b2cc72f1905d496468a1537fd9e36addc80"
readonly BRUIJN_COMMIT="9f1ac8856d09666a7444874f80b91b876929eecf"
readonly BRUIJN_SHA256="5186ffd7898f081d2961b1e2a4f9b207bc6104f1cff0372761c513d46815b7ca"
readonly LANGUAGE84_VERSION="0.8"
readonly LANGUAGE84_SHA256="b51807d1b7d06f1fdba762fdbf99c8c7fe762ec1a0c96c0be054657c9551cec0"

dotenv_excludes=(
  "--exclude=.env"
  "--exclude=*/.env"
  "--exclude=*.env"
  "--exclude=.env.*"
  "--exclude=*/.env.*"
  "--exclude=*.env.*"
)

download_and_verify() {
  local url=$1
  local output=$2
  local sha256=$3

  curl --fail --location --retry 3 --show-error --silent \
    --output "$output" "$url"
  printf '%s  %s\n' "$sha256" "$output" | sha256sum --check -
}

install_arkscript() {
  local archive="$RUNNER_TEMP/arkscript-${ARK_VERSION}.zip"
  local root="$RUNNER_TEMP/arkscript-${ARK_VERSION}"

  download_and_verify \
    "https://github.com/ArkScript-lang/Ark/releases/download/v${ARK_VERSION}/linux-clang-16.zip" \
    "$archive" \
    "$ARK_SHA256"

  mkdir -p "$root"
  unzip -q "$archive" -d "$root" -x \
    '.env' '*/.env' '*.env' '.env.*' '*/.env.*' '*.env.*'
  chmod +x "$root/arkscript"
  "$root/arkscript" --version
  printf '%s\n' "$root" >> "$GITHUB_PATH"
}

install_fatscript() {
  docker pull "$FAT_IMAGE"
}

install_bruijn() {
  local cache="$RUNNER_TEMP/bruijn-tool-v1.tar.gz"
  local tool="$RUNNER_TEMP/bruijn-tool"

  mkdir -p "$tool"
  if [ -f "$cache" ]; then
    tar "${dotenv_excludes[@]}" -xzf "$cache" -C "$tool"
  else
    local archive="$RUNNER_TEMP/bruijn-${BRUIJN_COMMIT}.tar.gz"
    local source="$RUNNER_TEMP/bruijn-source"
    local stack_root="$RUNNER_TEMP/bruijn-stack-root"

    download_and_verify \
      "https://github.com/marvinborner/bruijn/archive/${BRUIJN_COMMIT}.tar.gz" \
      "$archive" \
      "$BRUIJN_SHA256"

    mkdir -p "$source" "$tool/bin" "$tool/share"
    tar "${dotenv_excludes[@]}" -xzf "$archive" -C "$source" \
      --strip-components=1

    (
      cd "$source"
      stack --stack-root "$stack_root" \
        --local-bin-path "$tool/bin" \
        --no-terminal \
        install
    )

    local install_root
    local data_dir
    install_root=$(
      cd "$source"
      stack --stack-root "$stack_root" --no-terminal path --local-install-root
    )
    data_dir=$(printf '%s\n' "$install_root"/share/*/bruijn-0.1.0.0)
    [ -f "$data_dir/config" ]

    tar "${dotenv_excludes[@]}" -cf - -C "$data_dir" . |
      tar "${dotenv_excludes[@]}" -xf - -C "$tool/share"
    tar "${dotenv_excludes[@]}" -czf "$cache" -C "$tool" .
  fi

  [ -x "$tool/bin/bruijn" ]
  [ -f "$tool/share/config" ]
  printf '%s\n' "$tool/bin" >> "$GITHUB_PATH"
  printf 'bruijn_datadir=%s\n' "$tool/share" >> "$GITHUB_ENV"
}

install_language84() {
  local archive="$RUNNER_TEMP/language84-${LANGUAGE84_VERSION}.tar.xz"
  local root="$RUNNER_TEMP/language84-${LANGUAGE84_VERSION}"

  download_and_verify \
    "https://norstrulde.org/language84/language84-${LANGUAGE84_VERSION}.tar.xz" \
    "$archive" \
    "$LANGUAGE84_SHA256"

  mkdir -p "$root"
  tar "${dotenv_excludes[@]}" -xJf "$archive" -C "$root" \
    --strip-components=1
  [ -f "$root/84_stable.c" ]
  printf 'LANGUAGE84_HOME=%s\n' "$root" >> "$GITHUB_ENV"
}

install_arkscript
install_fatscript
install_bruijn
install_language84
