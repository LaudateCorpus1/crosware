#
# XXX - gitlab instance, not sure SHA-256 will always be the same for archive...
# XXX - fix symlinks nvi bin, nex/nview symlinks
#

rname="nvi"
rver="1.81.6-15"
rdir="${rname}-debian-${rver}"
rfile="${rdir}.tar.bz2"
rurl="https://salsa.debian.org/debian/${rname}/-/archive/debian/${rver}/${rfile}"
rsha256="2393da32c0c6059ae54c0989c7094a18063e6d36e919d94a251c686be1deb6b4"
rreqs="make netbsdcurses bdb47 configgit slibtool"

. "${cwrecipe}/common.sh"

eval "
function cwconfigure_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  local p
  for p in \$(cat debian/patches/series) ; do
    patch -p1 < debian/patches/\${p}
  done
  unset p
  rm -f dist/config.{sub,guess}
  install -m 0755 ${cwsw}/configgit/current/config.sub dist/
  install -m 0755 ${cwsw}/configgit/current/config.guess dist/
  cd build.unix
  ../dist/configure ${cwconfigureprefix} ${cwconfigurelibopts} \
    --program-prefix=n \
    --with-db=system \
    --disable-gtk \
    --disable-motif \
    --disable-perlinterp \
    --disable-tclinterp \
    --disable-dynamic-loading \
    --without-x \
      CPPFLAGS=\"-I${cwsw}/netbsdcurses/current/include -I${cwsw}/bdb47/current/include\" \
      LDFLAGS=\"-static -L${cwsw}/netbsdcurses/current/lib -L${cwsw}/bdb47/current/lib\" \
      LIBS='-lcurses -lterminfo -ldb -static'
  popd >/dev/null 2>&1
}
"

eval "
function cwmake_${rname}() {
  pushd \"${rbdir}/build.unix\" >/dev/null 2>&1
  make -j${cwmakejobs} ${rlibtool}
  popd >/dev/null 2>&1
}
"

eval "
function cwmakeinstall_${rname}() {
  pushd \"${rbdir}/build.unix\" >/dev/null 2>&1
  make install-strip ${rlibtool}
  popd >/dev/null 2>&1
}
"
eval "
function cwgenprofd_${rname}() {
  echo 'append_path \"${rtdir}/current/bin\"' > \"${rprof}\"
}
"
