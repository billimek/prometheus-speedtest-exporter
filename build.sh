#!/usr/bin/env bash

usage() {
  echo "Usage: $0 [cron]"
}

array_join() {
  local IFS="$1"
  shift
  echo "$*"
}

get_available_architectures() {
  local image="$1"
  local tag="${2:-latest}"

  docker buildx imagetools inspect --raw "${image}:${tag}" | \
    jq -r '.manifests[].platform | .os + "/" + .architecture + "/" + .variant' | \
    sed 's#/$##' | sort
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  set -ex

  cd "$(readlink -f "$(dirname "$0")")" || exit 9

  # Defaults
  DOCKERFILE="${DOCKERFILE:-Dockerfile}"
  IMAGE_NAME="${IMAGE_NAME:-billimek/speedtest}"
  TAG="${TAG:-latest}"

  case "$1" in
    latest)
      DOCKERFILE=Dockerfile
      TAG=latest
      shift
      ;;
    help|h|--help|-h)
      usage
      exit 0
      ;;
  esac

  EXTRA_BUILD_ARGS=()

  case "$1" in
    push|p|--push|-p)
      EXTRA_BUILD_ARGS+=("--push")
      ;;
    *)
      EXTRA_BUILD_ARGS+=("--load")
      ;;
  esac

  # NOTE: Ookla doesn't provide binaries for ppcle64 or s390x
  # read -r base_image base_tag <<< \
  #   "$(sed -nr 's/^FROM\s+([^:]+):?((\w+).*)\s*$/\1 \3/p' "$DOCKERFILE" | head -1)"
  # shellcheck disable=2207
  # platforms=($(get_available_architectures "$base_image" "$base_tag"))
  platforms=(
    linux/amd64
    linux/arm/v6
    linux/arm/v7
    linux/arm64/v8
  )

  BUILD_TYPE=manual

  if [[ "$TRAVIS" == "true" ]]
  then
    BUILD_TYPE=travis
    EXTRA_BUILD_ARGS+=("--no-cache")
  elif [[ "$GITHUB_ACTIONS" == "true" ]]
  then
    BUILD_TYPE=github
    EXTRA_BUILD_ARGS+=("--no-cache")
  fi

  docker buildx build \
    --file "$DOCKERFILE" \
    --platform "$(array_join "," "${platforms[@]}")" \
    --label=built-by=billimek \
    --label=build-type="$BUILD_TYPE" \
    --label=built-on="$HOSTNAME" \
    --tag "${IMAGE_NAME}:${TAG}" \
    "${EXTRA_BUILD_ARGS[@]}" \
    .
fi
