#
# XXX - libbsd support, add USELIBBSD=1 - doesn't seem to require libmd?
#

rname="sslh"
rver="1.22c"
rdir="${rname}-${rver}"
rfile="v${rver}.tar.gz"
rurl="https://github.com/yrutschle/${rname}/archive/refs/tags/${rfile}"
rsha256="ec5f6998f90b2849d113f2617db7ceca5281fbe4ef55fcd185789d390c09eb04"
rreqs="make pcre libconfig libcap"

. "${cwrecipe}/common.sh"

eval "
function cwconfigure_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  sed -i.ORIG '/^PREFIX/s,PREFIX.*,PREFIX=${ridir},g' Makefile
  sed -i 's/-lpcreposix/-lpcreposix -lpcre/g' Makefile
  popd >/dev/null 2>&1
}
"

eval "
function cwmake_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  make -j${cwmakejobs} \
    ENABLE_REGEX=1 \
    USELIBPCRE=1 \
    USELIBCONFIG=1 \
    USELIBCAP=1
  popd >/dev/null 2>&1
}
"

eval "
function cwmakeinstall_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  make install
  install -m 0755 ${rname}-fork \"${ridir}/sbin/\"
  install -m 0755 ${rname}-select \"${ridir}/sbin/\"
  ln -sf ${rname}-fork \"${ridir}/sbin/${rname}\"
  popd >/dev/null 2>&1
}
"

eval "
function cwgenprofd_${rname}() {
  echo 'append_path \"${rtdir}/current/sbin\"' > \"${rprof}\"
}
"
