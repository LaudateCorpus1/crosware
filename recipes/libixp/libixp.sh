rname="libixp"
rver="a7c1a33b2faace644b4adb7ea84bbd600e335048"
rdir="${rname}-${rver}"
rfile="${rver}.zip"
rurl="https://github.com/0intro/${rname}/archive/${rfile}"
rsha256="a884e9dd54d53ddeebbf1cbbaf04c1d93de1f8397c6d439f3e192d376d1049ce"
rreqs="bootstrapmake"

. "${cwrecipe}/common.sh"

# XXX - man pages require txt2tags, python - just disable and run install twice
eval "
function cwconfigure_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  cat config.mk > config.mk.ORIG
  sed -i \"/^CC/s,^.*,CC=\${CC} -c,g\" config.mk
  sed -i '/^LIBS/s,^.*,LIBS=-static,g' config.mk
  sed -i '/^PREFIX/s,^.*,PREFIX=${ridir},g' config.mk
  sed -i 's,-I/usr/include,,g' config.mk
  sed -i.ORIG 's,man,include,g' Makefile
  popd >/dev/null 2>&1
}
"

eval "
function cwmake_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  make
  popd >/dev/null 2>&1
}
"

eval "
function cwgenprofd_${rname}() {
  echo 'append_path \"${rtdir}/current/bin\"' > \"${rprof}\"
}
"

# echo 'append_cppflags \"-I${rtdir}/current/include\"' >> \"${rprof}\"
# echo 'append_ldflags \"-L${rtdir}/current/lib\"' >> \"${rprof}\"
