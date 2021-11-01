#
# XXX - --enable-aesgcm-stream --enable-ed25519-stream --enable-ed448-stream
#

rname="wolfssl"
rver="5.0.0"
rdir="${rname}-${rver}-stable"
rfile="${rdir}.tar.xz"
rurl="https://github.com/ryanwoodsmall/crosware-source-mirror/raw/master/${rname}/${rfile}"
rsha256="1356d8f93a3bd9b86c12bc7b88277bdfcfa260aa41a7959682fe725b1d3440aa"
rreqs="make cacertificates configgit"

. "${cwrecipe}/common.sh"

eval "
function cwconfigure_${rname}() {
  pushd "${rbdir}" >/dev/null 2>&1
  touch wolfssl/wolfcrypt/fips.h
  touch cyassl/ctaocrypt/fips.h
  sed -i '/^#!/s#/bin/sh#/usr/bin/env bash#g' configure
  bash ./configure ${cwconfigureprefix} ${cwconfigurelibopts} \
    --disable-asm \
    --disable-examples \
    --disable-fips \
    --disable-opensslall \
    --disable-opensslcoexist \
    --disable-opensslextra \
    --enable-aesccm \
    --enable-aesctr \
    --enable-aeskeywrap \
    --enable-anon \
    --enable-arc4 \
    --enable-alpn \
    --enable-atomicuser \
    --enable-blake2 \
    --enable-blake2s \
    --enable-camellia \
    --enable-certext \
    --enable-certgen \
    --enable-certreq \
    --enable-cmac \
    --enable-crl \
    --enable-crl-monitor \
    --enable-curve25519 \
    --enable-curve448 \
    --enable-des3 \
    --enable-dsa \
    --enable-dtls \
    --enable-ecccustcurves \
    --enable-eccencrypt \
    --enable-ed25519 \
    --enable-fpecc \
    --enable-hc128 \
    --enable-hkdf \
    --enable-idea \
    --enable-indef \
    --enable-jobserver=no \
    --enable-keygen \
    --enable-maxfragment \
    --enable-mcast \
    --enable-md2 \
    --enable-md4 \
    --enable-nullcipher \
    --enable-ocsp \
    --enable-ocspstapling \
    --enable-ocspstapling2 \
    --enable-oldnames \
    --enable-pkcallbacks \
    --enable-pkcs7 \
    --enable-pkcs11 \
    --enable-pkcs12 \
    --enable-psk \
    --enable-pwdbased \
    --enable-rabbit \
    --enable-renegotiation-indication \
    --enable-ripemd \
    --enable-rsapss \
    --enable-savecert \
    --enable-savesession \
    --enable-scep \
    --enable-scrypt \
    --enable-session-ticket \
    --enable-sni \
    --enable-srp \
    --enable-ssh \
    --enable-sslv3 \
    --enable-tls13 \
    --enable-tlsv10 \
    --enable-tlsx \
    --enable-trustedca \
    --enable-truncatedhmac \
    --enable-x963kdf \
      CFLAGS=\"\${CFLAGS}\" \
      LDFLAGS=-static \
      CPPFLAGS=
  popd >/dev/null 2>&1
}
"

eval "
function cwmakeinstall_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  make install ${rlibtool}
  test -e \"${ridir}/include/wolfssl/options.h\" || cp wolfssl/options.h \"${ridir}/include/wolfssl/\"
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
