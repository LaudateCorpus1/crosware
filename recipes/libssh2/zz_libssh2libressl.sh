rname="libssh2libressl"
rver="$(cwver_libssh2)"
rdir="$(cwdir_libssh2)"
rfile="$(cwfile_libssh2)"
rdlfile="$(cwdlfile_libssh2)"
rurl="$(cwurl_libssh2)"
rsha256=""
rreqs="make zlib libressl"

. "${cwrecipe}/common.sh"

eval "
function cwfetch_${rname}() {
  cwfetch_${rname%libressl}
}
"

eval "
function cwconfigure_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  ./configure ${cwconfigureprefix} ${cwconfigurelibopts} \
    --with-libssl-prefix=\"${cwsw}/libressl/current\" \
    --with-libz \
    --with-pic \
      CPPFLAGS=\"\$(echo -I${cwsw}/{libressl,zlib}/current/include)\" \
      LDFLAGS=\"\$(echo -L${cwsw}/{libressl,zlib}/current/lib) -static\" \
      LIBS=\"-lz -static\" \
      PKG_CONFIG_{LIBDIR,PATH}=
  sed -i 's/Requires.private/Requires/g' libssh2.pc
  sed -i 's#${ridir}#${rtdir}/current#g' libssh2.pc
  sed -i '/^Libs:/s|\$| -L${cwsw}/libressl/current/lib -lssl -lcrypto -L${cwsw}/zlib/current/lib -lz|g' libssh2.pc
  grep -ril '<sys/poll.h>' . | xargs sed -i.ORIG 's#<sys/poll.h>#<poll.h>#g'
  popd >/dev/null 2>&1
}
"
