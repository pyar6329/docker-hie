# syntax=docker/dockerfile:1.0-experimental
ARG GHC_VERSION

FROM pyar6329/haskell:llvm-8.8.3 AS hie-build

ARG GHC_VERSION
ARG HIE_VERSION
ARG GHC_RESOLVER_VERSION

USER root

RUN set -x && \
  apt-get update && \
  apt-get install -y libicu-dev libtinfo-dev libgmp-dev

USER haskell
WORKDIR /app

RUN set -x && \
  git clone --recursive -b ${HIE_VERSION} --single-branch --depth=1 https://github.com/haskell/haskell-ide-engine.git

WORKDIR /app/haskell-ide-engine

RUN set -x && \
  sed '/^$/d' -i /home/haskell/.stack/config.yaml && \
  sed -e "s/^resolver:.*/resolver: ${GHC_RESOLVER_VERSION}/g" -i install/shake.yaml && \
  stack ./install.hs hie-${GHC_VERSION}

FROM pyar6329/haskell:llvm-8.6.5 AS hie-data-build

ARG GHC_VERSION
ARG HIE_VERSION
ARG GHC_RESOLVER_VERSION
# hoogle doesn't exist in lts-15.14 (ghc-8.8.3), so use lts-14.27 (ghc-8.6.5)
ARG HOOGLE_GHC_RESOLVER_VERSION="lts-14.27"

USER root

RUN set -x && \
  apt-get update && \
  apt-get install -y libicu-dev libtinfo-dev libgmp-dev

USER haskell
WORKDIR /app

RUN set -x && \
  git clone --recursive -b ${HIE_VERSION} --single-branch --depth=1 https://github.com/haskell/haskell-ide-engine.git

WORKDIR /app/haskell-ide-engine

RUN set -x && \
  sed '/^$/d' -i /home/haskell/.stack/config.yaml && \
  sed -e "s/^resolver:.*/resolver: ${HOOGLE_GHC_RESOLVER_VERSION}/g" -i install/shake.yaml && \
  stack ./install.hs data

FROM pyar6329/haskell:base-${GHC_VERSION} AS hie

COPY --from=hie-build --chown=root:root /home/haskell/.local/bin/. /usr/local/bin/
COPY --from=hie-data-build --chown=haskell:haskell /home/haskell/.hoogle /home/haskell/.hoogle
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["--wait"]

FROM hie AS stack-update

RUN set -x && \
  stack --no-terminal update

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["--wait"]

FROM pyar6329/hie:base-${GHC_VERSION} AS hie-cron

RUN set -x && \
  stack --no-terminal update

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["--wait"]
