#!/bin/bash

echo "hello action with docker"

echo "about-til='thisisTIL'" > ${GITHUB_OUTPUT:-/dev/stdout}

if [[ $1 =~ "generateREADME.sh" ]]; then
  set -- $@ -f README.md
  exec $@
fi

exec "$@" 
