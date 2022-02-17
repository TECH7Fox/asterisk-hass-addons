[general]
enabled=yes
bindaddr=0.0.0.0
bindport=8088
{{ if .ssl -}}
tlsenable=yes
tlsbindaddr=0.0.0.0:8089
tlscertfile={{ .certfile }}
tlsprivatekey={{ .keyfile }}
{{- end }}
