#!/bin/bash

GITCONFIG=$(cat << 'EOF'
[credential]
  helper = store
[url "https://github.com/"]
  insteadOf = ssh://git@github.com/
  insteadOf = git@github.com:
EOF
)

if [ -n "${GITHUB_TOKEN}" ]; then
  if ! [ -e "${HOME}/.git-credentials" ]; then
    echo "https://${GITHUB_TOKEN}:@github.com" > ${HOME}/.git-credentials
  fi
  if ! [ -e "${HOME}/.gitconfig" ]; then
    echo "${GITCONFIG}" > ${HOME}/.gitconfig
  fi
fi

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

case "$1" in
  "--wait" ) trap : TERM INT; sleep infinity & wait;;
  * ) $@;;
esac
