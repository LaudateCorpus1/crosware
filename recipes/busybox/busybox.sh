rname="busybox"
rver="1.29.1"
rdir="${rname}-${rver}"
rfile="${rdir}.tar.bz2"
rurl="http://${rname}.net/downloads/${rfile}"
rsha256="fc250730ea16d28839bfecda3c431683fa6bd4273ffca6b632cbeb3556c914c3"
rreqs="make"

. "${cwrecipe}/common.sh"

eval "
function cwconfigure_${rname}() {
  pushd "${rbdir}" >/dev/null 2>&1
  curl -kLsO https://raw.githubusercontent.com/ryanwoodsmall/${rname}-misc/master/scripts/bb_config_script.sh
  sed -i.ORIG 's/^make/#make/g;s/^test/#test/g' bb_config_script.sh
  make defconfig HOSTCC=\"\${CC} -static\"
  bash bb_config_script.sh -m -s
  make oldconfig HOSTCC=\"\${CC} -static\"
  popd >/dev/null 2>&1
}
"

eval "
function cwmake_${rname}() {
  pushd "${rbdir}" >/dev/null 2>&1
  make -j${cwmakejobs} CC=\"\${CC}\" HOSTCC=\"\${CC} -static\" CFLAGS=\"\${CFLAGS}\" HOSTCFLAGS=\"\${CFLAGS}\" HOSTLDFLAGS=\"\${LDFLAGS}\"
  popd >/dev/null 2>&1
}
"

eval "
function cwmakeinstall_${rname}() {
  pushd "${rbdir}" >/dev/null 2>&1
  cwmkdir "${ridir}/bin"
  rm -f "${ridir}/bin/${rname}"
  cp -a "${rname}" "${ridir}/bin"
  for a in \$(./${rname} --list) ; do
    ln -sf "${ridir}/bin/${rname}" "${ridir}/bin/\${a}"
  done
  popd >/dev/null 2>&1
}
"

eval "
function cwgenprofd_${rname}() {
  echo 'append_path \"${rtdir}/current/bin\"' > "${rprof}"
  echo 'export PAGER=\"less\"' >> "${rprof}"
  echo 'export MANPAGER=\"less -R\"' >> "${rprof}"
}
"
