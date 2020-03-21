FROM pyar6329/haskell:8.6.4-llvm AS hie-build

ARG GHC_VERSION
ARG HIE_VERSION

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
  sed -e 's/install-ghc: false//g' -i /home/haskell/.stack/config.yaml && \
  sed '/^$/d' -i /home/haskell/.stack/config.yaml && \
  stack ./install.hs help

RUN set -x && \
  stack ./install.hs hie-${GHC_VERSION}

RUN set -x && \
  stack ./install.hs data

ARG FLAVOR=8.6.5-base
FROM pyar6329/haskell:${FLAVOR} AS hie

COPY --from=hie-build /home/haskell/.local/bin/. /usr/local/bin/
COPY --from=hie-build /home/haskell/.hoogle /home/haskell/.hoogle

CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"

FROM hie AS stack-update

RUN set -x && \
  stack --no-terminal update

CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"

