#
# XXX - uses separate openssldir in ${cwtop}/etc/libressl
# XXX - broken on centos 6, ugh
#
rname="libressl"
rver="3.1.4"
rdir="${rname}-${rver}"
rfile="${rdir}.tar.gz"
rurl="https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/${rfile}"
rsha256="414c149c9963983f805a081db5bd3aec146b5f82d529bb63875ac941b25dcbb6"
rreqs="make cacertificates"
# prefer openssl for now
rprof="${cwetcprofd}/zz_${rname}.sh"

. "${cwrecipe}/common.sh"

eval "
function cwconfigure_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  ./configure ${cwconfigureprefix} ${cwconfigurelibopts} ${rconfigureopts} ${rcommonopts} \
    --disable-asm \
    --enable-nc \
    --with-openssldir=\"${cwetc}/${rname}\" \
    --with-pic \
      CPPFLAGS= \
      LDFLAGS=-static
  popd >/dev/null 2>&1
}
"

eval "
function cwmakeinstall_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  make install ${rlibtool}
  ln -sf \"${rtdir}/current/bin/openssl\" \"${ridir}/bin/${rname}\"
  popd >/dev/null 2>&1
}
"

eval "
function cwgenprofd_${rname}() {
  echo 'append_path \"${rtdir}/current/bin\"' > \"${rprof}\"
  echo 'append_ldflags \"-L${rtdir}/current/lib\"' >> \"${rprof}\"
  echo 'append_cppflags \"-I${rtdir}/current/include\"' >> \"${rprof}\"
  echo 'append_pkgconfigpath \"${rtdir}/current/lib/pkgconfig\"' >> \"${rprof}\"
}
"
