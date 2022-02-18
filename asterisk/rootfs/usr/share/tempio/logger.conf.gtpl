[general]

[logfiles]
{{ if eq .log_level "fatal" -}}
console => error

{{- else if eq .log_level "error" -}}
console => error

{{- else if eq .log_level "warning" -}}
console => warning,error

{{- else if eq .log_level "notice" -}}
console => notice,warning,error

{{- else if eq .log_level "info" -}}
console => verbose,notice,warning,error

{{- else if eq .log_level "debug" -}}
console => verbose,debug,notice,warning,error

{{- else if eq .log_level "trace" -}}
console => verbose,debug,notice,warning,error

{{- else if eq .log_level "all" -}}
console => dtmf,fax,verbose,debug,notice,warning,error

{{- end }}