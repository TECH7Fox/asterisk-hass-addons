; DON'T MODIFY THIS FILE, IT GET'S OVERWRITTEN!
; IF YOU REALLY WANT TO CHANGE sipjs-phone OR my-codecs, YOU CAN ADD THAT IN pjsip_custom.conf OR EVEN pjsip.conf

; For additional parameters go to https://wiki.asterisk.org/wiki/display/AST/Asterisk+18+Configuration_res_pjsip

{{ if .auto_add }}
{{ $secret := .auto_add_secret }}

; Common AUTH parameters (template)
[sipjs-phone-auth](!)
type=auth
auth_type=userpass
password={{ $secret }}

; Common AOR parameters (template)
[sipjs-phone-aor](!)
type=aor
max_contacts=5
remove_existing=yes
qualify_frequency=30

; Common ENDPOINT parameters (template)
[sipjs-phone-endpoint](!) 
type=endpoint
send_rpid=yes
send_pai=yes
device_state_busy_at=1
dtls_auto_generate_cert=yes
webrtc=yes
; Setting webrtc=yes is a shortcut for setting the following options:
; use_avpf=yes
; media_encryption=dtls
; dtls_verify=fingerprint
; dtls_setup=actpass
; ice_support=yes
; media_use_received_transport=yes
; rtcp_mux=yes
context=default
disallow=all
allow=ulaw,alaw,speex,gsm,g726,g723,opus
{{ if .video_support }}
allow=h263,h263p,h264,vp8
{{ end }}

{{  range $index, $person := .persons }}
{{   $extension := add 100 $index }}
[{{ $extension }}](sipjs-phone-aor)
[{{ $extension }}](sipjs-phone-auth)
username={{ $extension }}
[{{ $extension }}](sipjs-phone-endpoint)
aors={{ $extension }}
auth={{ $extension }}
callerid="{{ $person }}" <{{ $extension }}>
{{   end }}

{{ end }}
