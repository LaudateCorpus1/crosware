#
# - other ssl/tls providers
#   - gnutls, nss, ...
# - libssh2
#   - main package supports openssl
#   - copy of libssh2 bundled with libressl recipe
#   - other providers use libssh2libgcrypt
#     - requires libgcrypt, which needs libgpgerror
#     - libssh2 w/libgcrypt needs '--key id_rsa --pubkey id_rsa.pub' options?
#     - https://www.zufallsheld.de/2020/06/07/debugging-issues-libcurl-pubkey-authentication/
# - enable libidn2?
# - enable c-ares resolver?
# - add ngtcp2+nghttp3 (experimental, really needs openssl (with patches)? gnutls?)
# - zstd support?
# - brotli?
#

rname="curl"
rver="7.76.1"
rdir="${rname}-${rver}"
rfile="${rdir}.tar.bz2"
rurl="https://curl.haxx.se/download/${rfile}"
rsha256="7a8e184d7d31312c4ebf6a8cb59cd757e61b2b2833a9ed4f9bf708066e7695e9"
rreqs="make zlib openssl libssh2 expat libmetalink cacertificates nghttp2 pkgconfig"

. "${cwrecipe}/common.sh"

# ugly - multiple configs need this, can't rely on base openssl cwconfigure_curl running
eval "
function cwextract_${rname}() {
  cwextract \"${rdlfile}\" \"${cwbuild}\"
  pushd \"${rbdir}\" >/dev/null 2>&1
  #local ossldir=\"\$(${cwsw}/openssl/current/bin/openssl version -d | cut -f2 -d' ' | tr -d '\"')\"
  local ossldir=\"${cwetc}/ssl\"
  local cabundle=\"\${ossldir}/cert.pem\"
  sed -i.ORIG \"s#/etc/ssl/cert#\${ossldir}/cert#g\" configure
  sed -i \"/ \\/.*\\/ca-.*\\.crt/s# /.*/ca-.*crt# \${cabundle}#g\" configure
  popd >/dev/null 2>&1
}
"

eval "
function cwconfigure_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  ./configure ${cwconfigureprefix} ${cwconfigurelibopts} \
    --disable-dependency-tracking \
    --disable-maintainer-mode \
    --enable-ipv6 \
    --with-libmetalink=\"${cwsw}/libmetalink/current\" \
    --with-libssh2=\"${cwsw}/libssh2/current\" \
    --with-nghttp2=\"${cwsw}/nghttp2/current\" \
    --with-zlib=\"${cwsw}/zlib/current\" \
    --without-hyper \
    --without-libidn2 \
    --without-zstd \
    --without-bearssl \
    --without-mbedtls \
    --without-wolfssh \
    --without-wolfssl \
    --without-gnutls \
    --with-ssl=\"${cwsw}/openssl/current\" \
    --with-default-ssl-backend=openssl \
    --with-ca-bundle=\"${cwetc}/ssl/cert.pem\"  \
    --with-ca-path=\"${cwetc}/ssl/certs\" \
    --with-ca-fallback \
      LIBS='-L${cwsw}/expat/current/lib -lexpat'
  popd >/dev/null 2>&1
}
"

eval "
function cwmakeinstall_${rname}() {
  cwmakeinstall_${rname}_openssl
  #cwmakeinstall_${rname}_libressl
  #cwmakeinstall_${rname}_bearssl
  #cwmakeinstall_${rname}_mbedtls
  #cwmakeinstall_${rname}_wolfssl
}
"

eval "
function cwmakeinstall_${rname}_openssl() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  rm -f \"${ridir}/bin/${rname}\" \"${ridir}/bin/${rname}-openssl\"
  make install
  mv \"${ridir}/bin/${rname}\" \"${ridir}/bin/${rname}-openssl\"
  ln -sf \"${rtdir}/current/bin/${rname}-openssl\" \"${ridir}/bin/${rname}\"
  popd >/dev/null 2>&1
}
"

for s in bearssl libressl mbedtls wolfssl ; do
eval "
function cwmakeinstall_${rname}_${s}() {
  cwcheckinstalled ${rname}${s} || cwinstall_${rname}${s}
  cwscriptecho \"installing ${rname}-${s} binary in ${ridir}/bin\"
  cwmkdir \"${ridir}/bin\"
  install -m 0755 \"${cwsw}/${rname}${s}/current/bin/${rname}-${s}\" \"${ridir}/bin/curl-${s}\"
}
"
done
unset s

eval "
function cwgenprofd_${rname}() {
  echo 'append_path \"${rtdir}/current/bin\"' > "${rprof}"
  echo 'append_ldflags \"-L${rtdir}/current/lib\"' >> \"${rprof}\"
  echo 'append_pkgconfigpath \"${rtdir}/current/lib/pkgconfig\"' >> \"${rprof}\"
  echo 'append_cppflags \"-I${rtdir}/current/include\"' >> \"${rprof}\"
}
"
