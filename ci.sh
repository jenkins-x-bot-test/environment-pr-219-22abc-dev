#!/bin/bash

set -e
set -u
set -o pipefail

NAME=$1
ARCALOS_SHA="27d1d343ea6be1cd19001cb47307f4e5e889d198" #pragma: allowlist secret

git clone https://github.com/cloudbees/arcalos

pushd arcalos
  if [ "" != "${ARCALOS_SHA}" ]
  then
    export USE_RELEASED_TEMPLATE=false
    BRANCH_NAME="pr-${ARCALOS_SHA}"
    git fetch origin ${ARCALOS_SHA} && git branch ${BRANCH_NAME} ${ARCALOS_SHA} && git checkout ${BRANCH_NAME}
    git merge origin/master
    git log master..
  fi

  sed -i "s|BOOT_GIT_REF=.*$|BOOT_GIT_REF=$PULL_PULL_SHA|g" ./templates/.secrets.defaults
  cat ./templates/.secrets.defaults
  ./create_aps_consumer_project.sh $NAME
  ./deploy_aps.sh $NAME
  ./run_all_checks.sh $NAME
popd
