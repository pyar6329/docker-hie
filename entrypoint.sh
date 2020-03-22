#!/bin/bash

if ! [ -e "${STACK_ROOT}/global-project" ]; then
  WORKDIR="${PWD}"
  cd ${HOME}
  mkdir ${STACK_ROOT}/global-project
  echo "packages: []" > ${STACK_ROOT}/global-project/stack.yaml
  stack config set system-ghc --global true
  stack config set install-ghc --global false
  stack config set resolver ${GHC_RESOLVER_VERSION}
  cd ${WORKDIR}
fi

exec $@
