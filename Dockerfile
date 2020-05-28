# syntax=docker/dockerfile:1.0-experimental
ARG GHC_VERSION

FROM pyar6329/haskell:8.6.5 AS hie-build

ARG GHC_VERSION
ARG HIE_VERSION

USER root

RUN set -x && \
  apt-get update && \
  apt-get install -y libicu-dev libtinfo-dev libgmp-dev

USER haskell
WORKDIR /app

RUN set -x && \
  if [ "${GHC_VERSION}" = "8.8.3" ]; then \
    git clone --recursive --depth=1 https://github.com/haskell/haskell-ide-engine.git; \
  else \
    git clone --recursive -b ${HIE_VERSION} --single-branch --depth=1 https://github.com/haskell/haskell-ide-engine.git; \
  fi

WORKDIR /app/haskell-ide-engine

RUN set -x && \
  sed -e 's/install-ghc: false//g' -i /home/haskell/.stack/config.yaml && \
  sed '/^$/d' -i /home/haskell/.stack/config.yaml && \
  stack ./install.hs help

RUN set -x && \
  stack ./install.hs hie-${GHC_VERSION}

RUN set -x && \
  stack ./install.hs data

FROM pyar6329/haskell:base-${GHC_VERSION} AS hie

COPY --from=hie-build --chown=root:root /home/haskell/.local/bin/. /usr/local/bin/
COPY --from=hie-build --chown=haskell:haskell /home/haskell/.hoogle /home/haskell/.hoogle
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
