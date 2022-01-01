#
# XXX - need global terminfo db?
# XXX - i.e., "make terminfo/terminfo.cdb && cp terminfo/terminfo.cdb ${ridir}/share/"
# XXX - need TERM* environment vars?
# XXX - readline, libedit, slang bundled in install - hacky but ehh
# XXX - split out to {readline,libedit,slang}netbsdcurses? maybe not worth it...
# XXX - curses pkg-config files don't set -L or -I?
# XXX - oasis version? https://github.com/oasislinux/netbsd-curses
# XXX - install curses_private.h - see rogue
# XXX - define _curx and _cury
#

rname="netbsdcurses"
rver="0.3.2"
rdir="netbsd-curses-${rver}"
rfile="v${rver}.tar.gz"
rurl="https://github.com/sabotage-linux/netbsd-curses/archive/${rfile}"
rsha256="9d3ebd651e5f70b87b1327b01cbd7e0c01a0f036b4c1371f653b7704b11daf23"
rreqs="make configgit"
# we want this to come after ncurses
rprof="${cwetcprofd}/zz_${rname}.sh"

. "${cwrecipe}/common.sh"

eval "
function cwfetch_${rname}() {
  cwfetchcheck \"${rurl}\" \"${rdlfile}\" \"${rsha256}\"
  cwfetch_readline
  cwfetch_libedit
  cwfetch_slang
}
"

eval "
function cwextract_${rname}() {
  cwextract \"${rdlfile}\" \"${cwbuild}\"
  cwextract \"\$(cwdlfile_readline)\" \"${rbdir}\"
  cwextract \"\$(cwdlfile_libedit)\" \"${rbdir}\"
  cwextract \"\$(cwdlfile_slang)\" \"${rbdir}\"
}
"

eval "
function cwgenprofd_${rname}() {
  echo 'append_path \"${rtdir}/current/bin\"' > \"${rprof}\"
}
"
#  echo 'append_ldflags \"-L${rtdir}/current/lib\"' >> \"${rprof}\"
#  echo 'append_pkgconfigpath \"${rtdir}/current/lib/pkgconfig\"' >> \"${rprof}\"
#  echo 'append_cppflags \"-I${rtdir}/current/include\"' >> \"${rprof}\"

# XXX - full term list:
#       awk -F'|' '/\|/&&!/^(#|$|\t)/{print $1}' terminfo/terminfo | sort -u
# XXX - diff -Naur libterminfo/genterms{.ORIG,} || true
eval "
function cwconfigure_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  sed -i.ORIG '/(TERMINFODIR)/ s#TERMINFODIR=#TERMINFO=#g;s#(TERMINFODIR)#(PWD)/terminfo/terminfo#g' GNUmakefile
  cat libterminfo/genterms > libterminfo/genterms.ORIG
  sed -n '/^#/,/^TERMLIST=/p' libterminfo/genterms.ORIG > libterminfo/genterms
  egrep -v '^(#|\\t)' terminfo/terminfo \
  | cut -f1 -d'|' \
  | tr -d ',' \
  | sort -u \
  | egrep '^[a-zA-Z0-9]' >> libterminfo/genterms
  sed -n '/^\"$/,//p' libterminfo/genterms.ORIG >> libterminfo/genterms
  popd >/dev/null 2>&1
}
"

eval "
function cwmake_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  cd nbperf
  make nbperf CPPFLAGS='-I.. -DTERMINFO_COMPILE -DTERMINFO_DB -DTERMINFO_COMPAT' LDFLAGS='-static'
  cd ..
  make -j${cwmakejobs} all-static PREFIX=\"${ridir}\" CPPFLAGS='-I./ -I./libterminfo -DTERMINFO_COMPILE -DTERMINFO_DB -DTERMINFO_COMPAT' LDFLAGS='-static'
  popd >/dev/null 2>&1
}
"

eval "
function cwmakeinstall_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  # LN=echo will disable libncurses symlinks
  make install-static install-manpages PREFIX=\"${ridir}\" CPPFLAGS='-I./ -I./libterminfo' LDFLAGS='-static' LN='echo'
  rm -f ${ridir}/lib/pkgconfig/ncurses* ${ridir}/lib/pkgconfig/*w.pc
  make terminfo/terminfo.cdb
  cwmkdir \"${ridir}/share\"
  install -m 644 terminfo/terminfo.cdb \"${ridir}/share/\"
  cwmakeinstall_${rname}_readline
  cwmakeinstall_${rname}_libedit
  cwmakeinstall_${rname}_slang
  popd >/dev/null 2>&1
}
"

eval "
function cwmakeinstall_${rname}_readline() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  cd \"\$(cwdir_readline)\"
  env PATH=\"${ridir}/bin:\${PATH}\" ./configure \
    ${cwconfigureprefix} \
    ${cwconfigurelibopts} \
    --with-curses \
    ${cwconfigurefpicopts} \
      CPPFLAGS=\"-I${ridir}/include\" \
      LDFLAGS=\"-L${ridir}/lib -static\" \
      LIBS=\"-lcurses -lterminfo\" \
      PKG_CONFIG_LIBDIR= \
      PKG_CONFIG_PATH=
  make -j${cwmakejobs}
  make install
  popd >/dev/null 2>&1
}
"

eval "
function cwmakeinstall_${rname}_libedit() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  cd \"\$(cwdir_libedit)\"
  env PATH=\"${ridir}/bin:\${PATH}\" ./configure \
    ${cwconfigureprefix} \
    ${cwconfigurelibopts} \
    ${cwconfigurefpicopts} \
      CFLAGS=\"\${CFLAGS} -D__STDC_ISO_10646__=201206L\" \
      CPPFLAGS=\"-I${ridir}/include\" \
      LDFLAGS=\"-L${ridir}/lib -static\" \
      LIBS=\"-lcurses -lterminfo\" \
      PKG_CONFIG_LIBDIR= \
      PKG_CONFIG_PATH=
  make -j${cwmakejobs}
  make install
  popd >/dev/null 2>&1
}
"

eval "
function cwmakeinstall_${rname}_slang() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  cd \"\$(cwdir_slang)\"
  sed -i.ORIG \"s/TERMCAP=-ltermcap/TERMCAP='-lcurses -lterminfo'/g\" configure
  env PATH=\"${ridir}/bin:\${PATH}\" ./configure \
    ${cwconfigureprefix} \
    ${cwconfigurelibopts} \
    ${cwconfigurefpicopts} \
      CPPFLAGS=\"-I${ridir}/include\" \
      LDFLAGS=\"-L${ridir}/lib -static\" \
      LIBS=\"-lcurses -lterminfo\" \
      PKG_CONFIG_LIBDIR= \
      PKG_CONFIG_PATH=
  make -j${cwmakejobs} static
  make install-static
  popd >/dev/null 2>&1
}
"
