#
# XXX - lib only!
# XXX - separate openssl build? needed for app
# XXX - libxml2
# XXX - libev
# XXX - zlib
#

rname="nghttp2"
rver="1.46.0"
rdir="${rname}-${rver}"
rfile="${rdir}.tar.xz"
rurl="https://github.com/${rname}/${rname}/releases/download/v${rver}/${rfile}"
rsha256="1a68cc4a5732afb735baf50aaac3cb3a6771e49f744bd5db6c49ab5042f12a43"
rreqs="make busybox slibtool"

. "${cwrecipe}/common.sh"

eval "
function cwconfigure_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  ./configure \
    --disable-app \
    --disable-examples\
    --disable-python-bindings \
    ${cwconfigureprefix} \
    ${cwconfigurelibopts} \
    ${rconfigureopts} \
    ${rcommonopts} \
      CPPFLAGS= \
      LDFLAGS=-static \
      PKG_CONFIG_LIBDIR= \
      PKG_CONFIG_PATH=
  popd >/dev/null 2>&1
}
"

eval "
function cwmake_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  make -j${cwmakejobs} ${rlibtool} \
    CPPFLAGS= \
    LDFLAGS=-static \
    PKG_CONFIG_LIBDIR= \
    PKG_CONFIG_PATH=
  popd >/dev/null 2>&1
}
"

eval "
function cwmakeinstall_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  make install ${rlibtool} \
    CPPFLAGS= \
    LDFLAGS=-static \
    PKG_CONFIG_LIBDIR= \
    PKG_CONFIG_PATH=
  popd >/dev/null 2>&1
}
"

eval "
function cwgenprofd_${rname}() {
  echo 'append_path \"${rtdir}/current/bin\"' > \"${rprof}\"
  echo 'append_cppflags \"-I${rtdir}/current/include\"' >> \"${rprof}\"
  echo 'append_ldflags \"-L${rtdir}/current/lib\"' >> \"${rprof}\"
  echo 'append_pkgconfigpath \"${rtdir}/current/lib/pkgconfig\"' >> \"${rprof}\"
}
"
