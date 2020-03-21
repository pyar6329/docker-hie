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

FROM ubuntu:18.04 AS hie

ARG USERID=1000
ARG GROUPID=1000
ARG USERNAME=hie

ENV LANG="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    DEBIAN_FRONTEND=noninteractive

RUN set -x && \
  groupadd -r -g ${GROUPID} ${USERNAME} && \
  useradd -m -g ${USERNAME} -u ${USERID} -d /home/${USERNAME} -s /bin/bash ${USERNAME}

COPY --from=hie-build --chown=hie:hie /home/haskell/.local/bin/. /usr/local/bin/
COPY --from=hie-build --chown=hie:hie /home/haskell/.hoogle /home/hie/.hoogle

USER ${USERNAME}

WORKDIR /app

CMD ["/usr/local/bin/hie", "--lsp"]
