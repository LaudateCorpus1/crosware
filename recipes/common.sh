# XXX - add an associative array of rver/rreqs
# XXX - rbdir should include /${rname}/ - what will it break? not much...
: ${rbdir:="${cwbuild}/${rdir}"}
: ${rtdir:="${cwsw}/${rname}"}
: ${ridir:="${rtdir}/${rdir}"}
: ${rprof:="${cwetcprofd}/${rname}.sh"}
: ${rdlfile:="${cwdl}/${rname}/${rfile}"}
: ${rreqs:=""}
: ${rlibtool:=""}
: ${rconfigureopts:=""}
: ${rcommonopts:=""}
: ${rurl:=""}
: ${rsite:=""}
: ${rmessage:=}
: ${rpfile:="${cwrecipe}/${rname}/${rname}.patches"}

if [[ ${rlibtool} == "" && ${rreqs} =~ slibtool ]] ; then
  rlibtool="LIBTOOL='${cwsw}/slibtool/current/bin/slibtool-static -all-static'"
fi

cwconfigureprefix="--prefix=${ridir}"
cwconfigurelibopts="--enable-static --enable-static=yes --disable-shared --enable-shared=no"
cwconfigurefpicopts="CFLAGS=\"\${CFLAGS} -fPIC\" CXXFLAGS=\"\${CXXFLAGS} -fPIC\""

eval "
function cwname_${rname}() {
  echo \"${rname}\"
}
"

eval "
function cwfile_${rname}() {
  echo \"${rfile}\"
}
"

eval "
function cwdlfile_${rname}() {
  echo \"${rdlfile}\"
}
"

eval "
function cwdir_${rname}() {
  echo \"${rdir}\"
}
"

eval "
function cwtdir_${rname}() {
  echo \"${rtdir}\"
}
"

eval "
function cwidir_${rname}() {
  echo \"${ridir}\"
}
"

eval "
function cwver_${rname}() {
  echo \"${rver}\"
}
"

eval "
function cwurl_${rname}() {
  echo \"${rurl}\"
}
"

eval "
function cwprof_${rname}() {
  echo \"${rprof}\"
}
"

eval "
function cwsite_${rname}() {
  echo \"${rsite}\"
}
"

eval "
function cwmessage_${rname}() {
  echo \"${rmessage}\"
}
"

eval "
function cwclean_${rname}() {
  pushd \"${cwbuild}\" >/dev/null 2>&1
  rm -rf \"${rbdir}\"
  popd >/dev/null 2>&1
}
"

eval "
function cwfetch_${rname}() {
  cwfetchcheck \"${rurl}\" \"${rdlfile}\" \"${rsha256}\"
}
"

eval "
function cwreqs_${rname}() {
  echo \"${rreqs}\"
}
"

eval "
function cwlistreqs_${rname}() {
  cwreqs_${rname}
}
"

eval "
function cwcheckreqs_${rname}() {
  cwcheckuniq \"\${FUNCNAME[@]}\"
  for rreq in ${rreqs} ; do
    if ! \$(cwcheckinstalled \${rreq}) ; then
      cwscriptecho \"installing required recipe \${rreq}\"
      cwinstall_\${rreq}
      cwsourceprofile
    fi
  done
}
"

eval "
function cwconfigure_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  ./configure ${cwconfigureprefix} ${rconfigureopts} ${rcommonopts}
  popd >/dev/null 2>&1
}
"

eval "
function cwmake_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  make -j${cwmakejobs} ${rlibtool}
  popd >/dev/null 2>&1
}
"

eval "
function cwmakeinstall_${rname}() {
  pushd \"${rbdir}\" >/dev/null 2>&1
  make install ${rlibtool}
  popd >/dev/null 2>&1
}
"

eval "
function cwgenprofd_${rname}() {
  echo '# ${rname}' > \"${rprof}\"
}
"

eval "
function cwmarkinstall_${rname}() {
  cwmarkinstall \"${rname}\" \"${rver}\"
  cwmarkupgraded \"${rname}\"
}
"

eval "
function cwextract_${rname}() {
  cwextract \"${rdlfile}\" \"${cwbuild}\"
}
"

eval "
function cwlinkdir_${rname}() {
  cwlinkdir \"$(basename ${ridir})\" \"${rtdir}\"
}
"

if [ ! -e "${rpfile}" ] ; then
  eval "
  function cwfetchpatches_${rname}() {
    true
  }
  "
  eval "
  function cwpatch_${rname}() {
    true
  }
  "
else
  eval "
  function cwfetchpatches_${rname}() {
    local p
    local f
    local c
    local l
    local s
    cwscriptecho \"${rname}: found patchlist file ${rpfile}\"
    cat \"${rpfile}\" | while IFS=\"\$(printf '\n')\" read -r l ; do
      if [[ \${l} =~ ^# ]] ; then
        continue
      fi
      c=\"\$(echo \"\${l}\" | awk -F, '{print \$NF}')\"
      s=\"\$(echo \"\${l}\" | awk -F, '{print \$(NF-1)}')\"
      p=\"\$(echo \"\${l}\" | sed \"s/,\${s},\${c}//g\")\"
      f=\"${cwdl}/${rname}/\$(basename \${p})\"
      cwfetchcheck \"\${p}\" \"\${f}\" \"\${s}\"
    done
    unset p f c l s
  }
  "
  eval "
  function cwpatch_${rname}() {
    pushd \"${rbdir}\" >/dev/null 2>&1
    local p
    local f
    local c
    local l
    local s
    cwscriptecho \"${rname}: found patchlist file ${rpfile}\"
    cat \"${rpfile}\" | while IFS=\"\$(printf '\n')\" read -r l ; do
      if [[ \${l} =~ ^# ]] ; then
        continue
      fi
      c=\"\$(echo \"\${l}\" | awk -F, '{print \$NF}')\"
      s=\"\$(echo \"\${l}\" | awk -F, '{print \$(NF-1)}')\"
      p=\"\$(echo \"\${l}\" | sed \"s/,\${s},\${c}//g\")\"
      f=\"${cwdl}/${rname}/\$(basename \${p})\"
      cwscriptecho \"${rname}: applying patch \${f} with strip level \${c}\"
      patch -p\${c} < \"\${f}\"
    done
    unset p f c l s
    popd >/dev/null 2>&1
  }
  "
fi

eval "
function cwinstall_${rname}() {
  cwcheckuniq \"\${FUNCNAME[@]}\"
  cwclean_${rname}
  cwfetch_${rname}
  cwfetchpatches_${rname}
  cwcheckreqs_${rname}
  cwsourceprofile
  cwextract_${rname}
  cwpatch_${rname}
  cwfixupconfig_${rname}
  cwconfigure_${rname}
  cwmake_${rname}
  cwmakeinstall_${rname}
  cwlinkdir_${rname}
  cwgenprofd_${rname}
  cwmarkinstall_${rname}
  cwclean_${rname}
  if [ ! -z \"${rmessage}\" ] ; then
    cwpusharray cwmessages \"${rname}: ${rmessage}\"
  fi
}
"

eval "
function cwuninstall_${rname}() {
  pushd \"${cwsw}\" >/dev/null 2>&1
  rm -rf \"${rname}\"
  rm -f \"${rprof}\"
  rm -f \"${cwvarinst}/${rname}\"
  popd >/dev/null 2>&1
}
"

eval "
function cwupgrade_${rname}() {
  cwscriptecho \"upgrading ${rname}\"
  cwupgradereqs_${rname}
  cwscriptecho \"uninstalling ${rname}\"
  cwuninstall_${rname}
  cwscriptecho \"installing ${rname}\"
  cwinstall_${rname}
  cwmarkupgraded ${rname}
}
"

eval "
function cwupgradereqs_${rname}() {
  cwscriptecho \"checking req upgrades for ${rname}\"
  local r
  for r in ${rreqs} ; do
    cwcheckinstalled \${r} || cwinstall_\${r}
    cwcheckupgradable \${r} && cwupgrade_\${r} || true
    cwmarkedupgradable \${r} && cwupgrade_\${r} || true
  done
  unset r
}
"

# XXX - call cwupgradedeps_${d} recursively? could get very hairy
eval "
function cwupgradedeps_${rname}() {
  cwscriptecho \"upgrading any installed deps for ${rname}\"
  local deps=\"\$(cwgetinstalleddeps ${rname})\"
  local d
  for d in \${deps[@]} ; do
    cwsetupgradble \${d} || true
  done
  for d in \${deps[@]} ; do
    cwmarkedupgradable \${d} && cwupgrade_\${d} || true
  done
}
"

eval "
function cwupgradewithdeps_${rname}() {
  cwscriptecho \"upgrading ${rname} and any installed deps\"
  cwupgradereqs_${rname}
  cwscriptecho \"uninstalling ${rname}\"
  cwuninstall_${rname}
  cwscriptecho \"installing ${rname}\"
  cwinstall_${rname}
  cwmarkupgraded ${rname}
  cwupgradedeps_${rname}
}
"

if [[ ${rreqs} =~ configgit ]] ; then
  eval "
  function cwfixupconfig_${rname}() {
    cwscriptecho \"fixing up config files\"
    pushd \"${rbdir}\" >/dev/null 2>&1
    local c l
    for c in config.{guess,sub} ; do
      for l in \$(find . -name \${c}) ; do
        cwscriptecho \"- \${l}\"
        chmod 755 \"\${l}\"
        cat \"${cwsw}/configgit/current/\${c}\" > \"\${l}\"
      done
    done
    unset c l
    popd >/dev/null 2>&1
  }
  "
else
  eval "
  function cwfixupconfig_${rname}() {
    true
  }
  "
fi
