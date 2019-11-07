#!/usr/bin/env bash

#
# uninstall/rebuild/reinstall everything
#

function failexit() {
  echo "${1}"
  exit 1
}

td="$(cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)"
test -e "${td}/bin/crosware" || {
  failexit "could not find crosware top directory"
}
cw="${td}/bin/crosware"

${cw} list-installed | cut -f1 -d: | while read -r r ; do
  echo ${cw} uninstall ${r}
done

${cw} install statictoolchain ccache

${cw} list-recipes | while read -r r ; do
  echo ${r} 1>&2
  echo ${r} > /tmp/${r}.out
  ${cw} check-installed ${r} || ( time ( echo ${cw} install ${r} ; echo $? ) ) 2>&1 | tee -a /tmp/${r}.out
done >/tmp/crosware_rebuild.out 2>&1
