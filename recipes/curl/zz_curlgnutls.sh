rname="curlgnutls"
rreqs="gnutls libtasn1 libunistring nettle gmp"
rproviderreqs="${rreqs// /,}"
rcommonopts="LIBS='-lgnutls -ltasn1 -lunistring -lhogweed -lgmp -lnettle'"
. "${cwrecipe}/${rname%gnutls}/${rname%gnutls}tlsprovider.sh.common"
