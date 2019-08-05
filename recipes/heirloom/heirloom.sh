#
# XXX - build
#   - netbsdcurses works: set proper -I and -L, add '-DTPARM_VARARGS -DUSE_TERMCAP' to CPPFLAGS, set LCURS to '-lcurses -lterminfo'
#
# XXX - profile ordering
#   - use zz_00_heirloom.sh to come before 9base?
#
rname="heirloom"
rver="20190804-musl"
rdir="${rname}-project-${rver}"
rfile="${rver}.tar.gz"
rurl="https://github.com/ryanwoodsmall/${rname}-project/archive/${rfile}"
rsha256="7c9a27fbd80ea4954057750f3cefba7b0962ab1fd6004b49d15d32b98e5c1b13"
rreqs="make sed ncurses zlib bzip2 ed byacc reflex"
rprof="${cwetcprofd}/zz_${rname}.sh"

. "${cwrecipe}/common.sh"

eval "
function cwconfigure_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  grep -ril \"/usr/local/${rname}\" . \
  | xargs sed -i \"s#/usr/local/${rname}#${ridir}#g\"
  sed -i '/^LEX = /s/LEX.*/LEX=reflex/g' heirloom/build/mk.config
  sed -i '/^YACC = /s/YACC.*/YACC=byacc/g' heirloom/build/mk.config
  #sed -i '/^LCURS = /s/LCURS.*/LCURS = -lcurses -lterminfo/g' heirloom/build/mk.config
  #sed -i '/^CPPFLAGS/s/$/ -DTPARM_VARARGS -DUSE_TERMCAP/g' heirloom/build/mk.config
  #sed -i 's#/ncurses#/netbsdcurses#g' heirloom/build/mk.config
  #sed -i 's#/ncurses/#/netbsdcurses/#g' heirloom-ex-vi/Makefile
  #sed -i '/^TERMLIB/s/ncurses/curses/g' heirloom-ex-vi/Makefile
  #sed -i '/^#LDADD/s/.*/LDADD = -lcurses -lterminfo/g' heirloom-ex-vi/Makefile
  popd >/dev/null 2>&1
}
"

eval "
function cwmake_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  local d=''
  for d in ${rname}{,-{sh,devtools,doctools,ex-vi}} ; do
    pushd \${d}
    env CHARSET= PATH=\"${cwsw}/byacc/current/bin:${cwsw}/reflex/current/bin:\${PATH}\" make
    env CHARSET= PATH=\"${cwsw}/byacc/current/bin:${cwsw}/reflex/current/bin:\${PATH}\" make install
    popd
  done
  popd >/dev/null 2>&1
}
"

eval "
function cwmakeinstall_${rname}() {
  true
}
"

eval "
function cwgenprofd_${rname}() {
  echo 'append_path \"${rtdir}/current/5bin/posix2001\"' > \"${rprof}\"
  echo 'append_path \"${rtdir}/current/5bin/posix\"' >> \"${rprof}\"
  echo 'append_path \"${rtdir}/current/ucb\"' >> \"${rprof}\"
  echo 'append_path \"${rtdir}/current/ccs/bin\"' >> \"${rprof}\"
  echo 'append_path \"${rtdir}/current/5bin/s42\"' >> \"${rprof}\"
  echo 'append_path \"${rtdir}/current/5bin/sv3\"' >> \"${rprof}\"
  echo 'append_path \"${rtdir}/current/sbin\"' >> \"${rprof}\"
  echo 'append_path \"${rtdir}/current/bin\"' >> \"${rprof}\"
}
"
