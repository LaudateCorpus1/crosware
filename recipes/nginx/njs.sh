rname="njs"
rver="0.7.1"
rdir="${rname}-${rver}"
rfile="${rver}.tar.gz"
rurl="https://github.com/nginx/${rname}/archive/refs/tags/${rfile}"
rsha256="f5493b444ef54f1edba85c7adcbb1132e61c36d47de8f7a8d351965cad6d5486"
rreqs="libressl"
. "${cwrecipe}/nginx/${rname}.sh.common"
