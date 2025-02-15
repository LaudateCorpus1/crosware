#
# XXX
#   supports mbedtls, as does libgit2
#   libgit2 support down the road...
#   slibtool works, necessary?
#

rname="libssh2"
rver="1.10.0"
rdir="${rname}-${rver}"
rfile="${rdir}.tar.gz"
rurl="https://github.com/${rname}/${rname}/releases/download/${rdir}/${rfile}"
rsha256="2d64e90f3ded394b91d3a2e774ca203a4179f69aebee03003e5a6fa621e41d51"
rreqs="make openssl zlib"

. "${cwrecipe}/common.sh"

eval "
function cwconfigure_${rname}() {
  pushd "${rbdir}" >/dev/null 2>&1
  ./configure ${cwconfigureprefix} ${cwconfigurelibopts} --with-libssl-prefix=\"${cwsw}/openssl/current\" --with-libz
  #sed -i.ORIG '/Libs: /s/$/ -lssl -lcrypto -lz/g' libssh2.pc
  sed -i.ORIG 's/Requires.private/Requires/g' libssh2.pc
  sed -i.ORIG 's#${ridir}#${rtdir}/current#g' libssh2.pc
  sed -i.ORIG '/^Libs:/s|\$| -L${cwsw}/openssl/current/lib -lssl -lcrypto -L${cwsw}/zlib/current/lib -lz|g' libssh2.pc
  grep -ril '<sys/poll.h>' . | xargs sed -i.ORIG 's#<sys/poll.h>#<poll.h>#g'
  popd >/dev/null 2>&1
}
"

eval "
function cwgenprofd_${rname}() {
  echo 'append_cppflags \"-I${rtdir}/current/include\"' > \"${rprof}\"
  echo 'append_ldflags \"-L${rtdir}/current/lib\"' >> \"${rprof}\"
  echo 'append_pkgconfigpath \"${rtdir}/current/lib/pkgconfig\"' >> \"${rprof}\"
}
"
