#!/bin/sh

if  $(echo "$QUERY_STRING" | grep -q genconfigname ); then
	NAME=${QUERY_STRING##*genconfigname=}
	sh /mod/etc/default.openvpn/generate_virtual_pkg "$NAME"
	sed -i "/$NAME/ d" /tmp/flash/openvpn/configs
	echo "$NAME" >> /tmp/flash/openvpn/configs
fi

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

cginame=${0##*/}
pkgname=${cginame%%.cgi}
if [ "openvpn" == ${pkgname} ]; then
	filepath=/tmp/flash/openvpn/
else
	filepath=/tmp/flash/openvpn/${pkgname}/
fi

sec_begin '$(lang de:"Starttyp" en:"Start type")' sec_start

cgi_print_radiogroup_service_starttype \
	"enabled" "$OPENVPN_ENABLED" "" "" 1

sec_end
sec_begin '$(lang de:"Einstellungen" en:"Configuration")' sec_conf

cat << EOF
$(lang de:"Hinweis: Zertifikate und Keys liegen unter " en:"Certs and keys are located ") <i>${filepath}</i>
<p><div align="center">
<textarea id="id_conf" style="width: 500px;" name="conf" rows="15" cols="80"
 wrap="off" >$OPENVPN_CONF</textarea></div></p>

EOF

sec_end
