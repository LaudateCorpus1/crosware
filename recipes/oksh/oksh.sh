rname="oksh"
rver="7.0"
rdir="${rname}-${rver}"
rfile="${rdir}.tar.gz"
rurl="https://github.com/ibara/${rname}/releases/download/${rdir}/${rfile}"
rsha256="21d5891f38ffea3a5d1aa8c494f0a5579c93778535e0a92275b102dec3221da1"
rreqs="make netbsdcurses"
rprof="${cwetcprofd}/zz_${rname}.sh"

. "${cwrecipe}/common.sh"

eval "
function cwconfigure_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  sed -i.ORIG 's/ncurses\.h/curses.h/g' configure emacs.c var.c
  sed -i 's/-lncurses/-lcurses -lterminfo/g' configure
  env \
    CPPFLAGS= \
    CFLAGS=\"-I${cwsw}/netbsdcurses/current/include\" \
    LDFLAGS=\"-L${cwsw}/netbsdcurses/current/lib -lcurses -lterminfo -static\" \
      ./configure \
        --prefix=\"${ridir}\" \
        --bindir=\"${ridir}/bin\" \
        --mandir=\"${ridir}/share/man\" \
        --enable-curses \
        --enable-ksh \
        --enable-sh \
        --enable-static
  popd >/dev/null 2>&1
}
"

eval "
function cwmake_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  make -j${cwmakejobs} CPPFLAGS=
  popd >/dev/null 2>&1
}
"

eval "
function cwmakeinstall_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  find ${ridir}/bin/ ! -type d | grep 'sh$' | xargs rm -f
  make install
  mv \"${ridir}/bin/ksh\" \"${ridir}/bin/${rname}\"
  ln -sf \"${rtdir}/current/bin/${rname}\" \"${ridir}/bin/ksh\"
  ln -sf \"${rtdir}/current/bin/${rname}\" \"${ridir}/bin/sh\"
  popd >/dev/null 2>&1
}
"

eval "
function cwgenprofd_${rname}() {
  echo 'append_path \"${rtdir}/current/bin\"' > \"${rprof}\"
}
"
