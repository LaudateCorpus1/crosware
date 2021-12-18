rname="tinycurl772bearssl"
rver="$(cwver_tinycurl772)"
rdir="$(cwdir_tinycurl772)"
rfile="$(cwfile_tinycurl772)"
rdlfile="$(cwdlfile_tinycurl772)"
rurl="$(cwurl_tinycurl772)"
rsha256=""
rreqs="bearssl"

. "${cwrecipe}/tinycurl/tinycurl.sh.common"

for f in fetch clean extract make ; do
  eval "
  function cw${f}_${rname}() {
    cw${f}_${rname%bearssl}
  }
  "
done
unset f
