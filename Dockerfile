FROM alpine:latest

ENV SPEEDTEST_VERSION=1.0.0
ENV SCRIPT_EXPORTER_VERSION=v2.1.2

RUN apk add tar curl ca-certificates bash

RUN ARCH=$(apk info --print-arch) && \
    echo ARCH=$ARCH && \
    case "$ARCH" in \
      x86) _arch=i386 ;; \
      armv7) _arch=armhf ;; \
      *) _arch="$ARCH" ;; \
    esac && \
    echo https://bintray.com/ookla/download/download_file?file_path=ookla-speedtest-${SPEEDTEST_VERSION}-${_arch}-linux.tgz && \
    curl -fsSL -o /tmp/ookla-speedtest.tgz \
      https://bintray.com/ookla/download/download_file?file_path=ookla-speedtest-${SPEEDTEST_VERSION}-${_arch}-linux.tgz && \
    tar xvfz /tmp/ookla-speedtest.tgz -C /usr/local/bin speedtest && \
    rm -rf /tmp/ookla-speedtest.tgz

RUN ARCH=$(apk info --print-arch) && \
    case "$ARCH" in \
      x86_64) _arch=amd64 ;; \
      armhf) _arch=armv7 ;; \
      aarch64) _arch=arm64 ;; \
      *) _arch="$ARCH" ;; \
    esac && \
    echo https://github.com/ricoberger/script_exporter/releases/download/${SCRIPT_EXPORTER_VERSION}/script_exporter-linux-${_arch} && \
    curl -kfsSL -o /usr/local/bin/script_exporter \
      https://github.com/ricoberger/script_exporter/releases/download/${SCRIPT_EXPORTER_VERSION}/script_exporter-linux-${_arch} && \
    chmod +x /usr/local/bin/script_exporter

COPY config.yaml config.yaml
COPY speedtest-exporter.sh /usr/local/bin/speedtest-exporter.sh

EXPOSE 9469

ENTRYPOINT  [ "/usr/local/bin/script_exporter" ]
