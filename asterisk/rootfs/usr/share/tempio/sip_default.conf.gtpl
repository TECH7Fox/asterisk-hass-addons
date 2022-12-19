; DON'T MODIFY THIS FILE, IT GET'S OVERWRITTEN!
; IF YOU REALLY WANT TO CHANGE sipjs-phone OR my-codecs, YOU CAN ADD THAT IN sip_custom.conf OR EVEN sip.conf

[sipjs-phone](!)
type=friend
host=dynamic ; Allows any host to register
encryption=yes ; Tell Asterisk to use encryption for this peer
avpf=yes ; Tell Asterisk to use AVPF for this peer
icesupport=yes ; Tell Asterisk to use ICE for this peer
context=default ; Tell Asterisk which context to use when this peer is dialing
directmedia=no ; Asterisk will relay media for this peer
transport=wss,udp,tls ; Asterisk will allow this peer to register on UDP or WebSockets
force_avp=yes ; Force Asterisk to use avp. Introduced in Asterisk 11.11
dtlsenable=yes ; Tell Asterisk to enable DTLS for this peer
dtlsverify=fingerprint ; Tell Asterisk to verify DTLS fingerprint
dtlscertfile=/etc/asterisk/keys/asterisk.pem ; Tell Asterisk where your DTLS cert file is
dtlssetup=actpass ; Tell Asterisk to use actpass SDP parameter when setting up DTLS
rtcp_mux=yes ; Tell Asterisk to do RTCP mux
dtmfmode=rfc2833
qualify=no
sendrpid=pai
videosupport={{ .video_support }}
busylevel=1

[my-codecs](!)
allow=!all,ulaw,alaw,speex,gsm,g726,g723,h263,h263p,h264,vp8

{{ if .auto_add }}
{{ $secret := .auto_add_secret }}
{{  range $index, $person := .persons }}
{{   $extension := add 100 $index }}
[{{ $extension }}](sipjs-phone,my-codecs)
username={{ $extension }}
secret={{ $secret }}
callerid="{{ $person }}" <{{ $extension }}>
{{   end }}
{{ end }}
