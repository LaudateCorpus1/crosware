rname="ccache"
rver="3.7.12"
rdir="${rname}-${rver}"
rfile="${rdir}.tar.gz"
rurl="https://github.com/${rname}/${rname}/releases/download/v${rver}/${rfile}"
rsha256="d2abe88d4c283ce960e233583061127b156ffb027c6da3cf10770fc0c7244194"
rreqs="bootstrapmake"
rprof="${cwetcprofd}/zz_${rname}.sh"

. "${cwrecipe}/common.sh"

eval "
function cwconfigure_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  ./configure ${cwconfigureprefix} --with-bundled-zlib
  popd >/dev/null 2>&1
}
"

eval "
function cwmakeinstall_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  make install
  strip --strip-all \"${ridir}/bin/${rname}\"
  cd \"${ridir}/bin\"
  for p in cc cpp c++ gcc g++ ; do
    for a in ${statictoolchain_triplet[@]} musl ; do
      ln -sf ${rname} \${a}-\${p}
    done
    ln -sf ${rname} \${p}
  done
  popd >/dev/null 2>&1
}
"

eval "
function cwgenprofd_${rname}() {
  echo 'prepend_path \"${rtdir}/current/bin\"' > \"${rprof}\"
}
"
