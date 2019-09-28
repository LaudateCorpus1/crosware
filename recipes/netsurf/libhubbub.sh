rname="libhubbub"
rver="0.3.6"
rdir="${rname}-${rver}"
rfile="${rdir}-src.tar.gz"
rurl="http://download.netsurf-browser.org/libs/releases/${rfile}"
rsha256="d756c795c1a0e08beec4acd68364ac4477960d62fffa3b60da05f5a7763f7bf4"
rreqs="make pkgconfig perl bison flex byacc reflex expat libparserutils libwapcaplet"

. "${cwrecipe}/common.sh"
. "${cwrecipe}/netsurf/netsurf.sh.common"
