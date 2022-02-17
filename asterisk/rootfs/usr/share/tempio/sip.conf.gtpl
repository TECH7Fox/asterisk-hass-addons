[general]
udpbindaddr=0.0.0.0
bind=0.0.0.0
bindaddr=0.0.0.0
protocol=udp
{{ if .ssl -}}
tlsenable=yes
tlsbindaddr=0.0.0.0
tlscertfile=/etc/asterisk/keys/asterisk.pem
tlscipher=ALL
tlsclientmethod=ALL
{{- end }}

#include sip_default.conf

#include sip_custom.conf
