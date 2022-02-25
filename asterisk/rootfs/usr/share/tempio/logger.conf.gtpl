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
console => verbose(1),notice,warning,error

{{- else if eq .log_level "debug" -}}
console => verbose(2),debug,notice,warning,error

{{- else if eq .log_level "trace" -}}
console => verbose(3),debug,notice,warning,error

{{- else if eq .log_level "all" -}}
console => dtmf,fax,verbose(3),debug,notice,warning,error

{{- end }}
