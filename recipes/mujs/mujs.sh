rname="mujs"
rver="1.2.0"
rdir="${rname}-${rver}"
#rfile="${rdir}.tar.xz"
#rurl="https://${name}/downloads/${rfile}"
rfile="${rver}.tar.gz"
rurl="https://github.com/ccxvii/${rname}/archive/${rfile}"
rsha256="bbb74b96c168e7120f1aa2ce0a42026eba01cff14a9234108c91795f3a4c8cd0"
rreqs="make netbsdcurses"

. "${cwrecipe}/common.sh"

eval "
function cwconfigure_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  sed -i.ORIG 's/-lreadline/-lreadline -lcurses -lterminfo -static/g' Makefile
  popd >/dev/null 2>&1
}
"

eval "
function cwmake_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  make release prefix=\"${ridir}\" CC=\"\${CC} \${CFLAGS} -I${cwsw}/netbsdcurses/current/include -L${cwsw}/netbsdcurses/current/lib\" CPPFLAGS= LDFLAGS=-static
  popd >/dev/null 2>&1
}
"

eval "
function cwmakeinstall_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  make install prefix=\"${ridir}\" CC=\"\${CC} \${CFLAGS} -I${cwsw}/netbsdcurses/current/include -L${cwsw}/netbsdcurses/current/lib\" CPPFLAGS= LDFLAGS=-static
  \$(\${CC} -dumpmachine)-strip --strip-all \"${ridir}/bin/${rname}\"
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
