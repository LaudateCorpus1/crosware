cwconfigurelibopts="--enable-static --enable-static=yes --disable-shared --enable-shared=no"

eval "
function cwname_${rname}() {
  echo "${rname}"
}
"

eval "
function cwver_${rname}() {
  echo "${rver}"
}
"

eval "
function cwclean_${rname}() {
  pushd "${cwbuild}" >/dev/null 2>&1
  rm -rf "${rdir}"
  popd >/dev/null 2>&1
}
"

eval "
function cwfetch_${rname}() {
  cwfetchcheck "${rurl}" "${cwdl}/${rfile}" "${rsha256}"
}
"

eval "
function cwcheckreqs_${rname}() {
  for rreq in ${rreqs} ; do
    if ! \$(cwcheckinstalled \${rreq}) ; then
      cwinstall_\${rreq}
      cwsourceprofile
    fi
  done
}
"

eval "
function cwconfigure_${rname}() {
  pushd "${cwbuild}/${rdir}" >/dev/null 2>&1
  ./configure --prefix="${cwsw}/${rname}/${rdir}"
  popd >/dev/null 2>&1
}
"

eval "
function cwmake_${rname}() {
  pushd "${cwbuild}/${rdir}" >/dev/null 2>&1
  make -j$(($(nproc)+1))
  popd >/dev/null 2>&1
}
"

eval "
function cwmakeinstall_${rname}() {
  pushd "${cwbuild}/${rdir}" >/dev/null 2>&1
  make install
  popd >/dev/null 2>&1
}
"

eval "
function cwgenprofd_${rname}() {
  echo "\\\# ${rname}" > "${rprof}"
}
"

eval "
function cwmarkinstall_${rname}() {
  cwmarkinstall "${rname}" "${rver}"
}
"

eval "
function cwinstall_${rname}() {
  cwfetch_${rname}
  cwcheckreqs_${rname}
  cwsourceprofile
  cwclean_${rname}
  cwextract "${cwdl}/${rfile}" "${cwbuild}"
  cwconfigure_${rname}
  cwmake_${rname}
  cwmakeinstall_${rname}
  cwlinkdir "${rdir}" "${cwsw}/${rname}"
  cwgenprofd_${rname}
  cwmarkinstall_${rname}
  cwclean_${rname}
}
"

eval "
function cwuninstall_${rname}() {
  pushd "${cwsw}" >/dev/null 2>&1
  rm -rf "${rname}"
  rm -f "${rprof}"
  rm -f "${cwvarinst}/${rname}"
  popd >/dev/null 2>&1
}
"
