rname="tinyssh"
rver="20220101"
rdir="${rname}-${rver}"
rfile="${rver}.tar.gz"
rurl="https://github.com/janmojzis/${rname}/archive/refs/tags/${rfile}"
rsha256="b68e5b8d1f72304d70b25b53dd221cdc0a25730695bf4e8e08e27ece9dcb499d"
rreqs="bootstrapmake"

. "${cwrecipe}/common.sh"

# XXX - channel tests (at least) break on riscv64...
if [[ ${karch} =~ ^riscv64 ]] ; then
eval "
function cwinstall_${rname}() {
  cwscriptecho \"recipe ${rname} does not support architecture ${karch}\"
}
"
fi

eval "
function cwconfigure_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  echo '${ridir}/sbin' > conf-bin
  echo '${ridir}/share/man' > conf-man
  echo \"\${AR}\" > conf-ar
  echo \"\${CC}\" > conf-cc
  echo '-Wl,-static' >> conf-cflags
  echo '-static' >> conf-libs
  popd >/dev/null 2>&1
}
"

eval "
function cwmake_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  make CFLAGS= CPPFLAGS= CXXFLAGS= LDFLAGS= PKG_CONFIG_LIBDIR= PKG_CONFIG_PATH=
  popd >/dev/null 2>&1
}
"

eval "
function cwgenprofd_${rname}() {
  echo 'append_path \"${rtdir}/current/sbin\"' > \"${rprof}\"
}
"
