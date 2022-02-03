[general]

[logfiles]
{{ if .log_level == "default" }}
console => notice,warning,error
{{ else if .log_level == "verbose" }}
console => notice,warning,error,verbose
{{ else if .log_level == "increased" }}
console => notice,warning,error,verbose,dtmf,fax
{{ else if .log_level == "debug" }}
console => notice,warning,error,debug,verbose,dtmf,fax
