rname="cares"
rver="1.17.2"
rdir="c-ares-${rver}"
rfile="${rdir}.tar.gz"
rurl="https://github.com/c-ares/c-ares/releases/download/${rname}-${rver//./_}/${rfile}"
rsha256="4803c844ce20ce510ef0eb83f8ea41fa24ecaae9d280c468c582d2bb25b3913d"
rreqs="bootstrapmake"

. "${cwrecipe}/common.sh"

eval "
function cwconfigure_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  ./configure ${cwconfigureprefix} ${cwconfigurelibopts} ${rconfigureopts} ${rcommonopts} \
    --disable-tests \
      LDFLAGS=-static \
      CPPFLAGS= \
      PKG_CONFIG_LIBDIR= \
      PKG_CONFIG_PATH=
  popd >/dev/null 2>&1
}
"

eval "
function cwmakeinstall_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  local p
  make install ${rlibtool}
  cwmkdir \"${ridir}/bin\"
  for p in src/tools/a{country,dig,host} ; do
    install -m 0755 \${p} \"${ridir}/bin/\$(basename \${p})\"
  done
  popd >/dev/null 2>&1
}
"

#eval "
#function cwgenprofd_${rname}() {
#  echo 'append_cppflags \"-I${rtdir}/current/include\"' > \"${rprof}\"
#  echo 'append_ldflags \"-L${rtdir}/current/lib\"' >> \"${rprof}\"
#  echo 'append_pkgconfigpath \"${rtdir}/current/lib/pkgconfig\"' >> \"${rprof}\"
#}
#"
