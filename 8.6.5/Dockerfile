FROM pyar6329/haskell:8.6.4 AS hie-build

ARG GHC_VERSION="8.6.5"
ARG HIE_VERSION="1.2"

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
  stack ./install.hs help && \
  sed '4d' -i /home/haskell/.stack/config.yaml

RUN set -x && \
  stack ./install.hs hie-${GHC_VERSION} && \
  stack ./install.hs data

FROM ubuntu:18.04

ARG USERID=1000
ARG GROUPID=1000
ARG USERNAME=hie

ENV LANG="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    DEBIAN_FRONTEND=noninteractive

RUN set -x && \
  groupadd -r -g ${GROUPID} ${USERNAME} && \
  useradd -m -g ${USERNAME} -u ${USERID} -d /home/${USERNAME} -s /bin/bash ${USERNAME}

COPY --from=hie-build --chown=hie:hie /home/haskell/.local/bin/hie /usr/local/bin/hie
COPY --from=hie-build --chown=hie:hie /home/haskell/.local/bin/hie-8.6 /usr/local/bin/hie-8.6
COPY --from=hie-build --chown=hie:hie /home/haskell/.local/bin/hie-8.6.5 /usr/local/bin/hie-8.6.5
COPY --from=hie-build --chown=hie:hie /home/haskell/.local/bin/hie-wrapper /usr/local/bin/hie-wrapper

USER ${USERNAME}

WORKDIR /app

CMD ["/usr/local/bin/hie"]
