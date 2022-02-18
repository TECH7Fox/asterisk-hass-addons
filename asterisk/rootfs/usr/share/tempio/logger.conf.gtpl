[general]

[logfiles]
{{ else if .log_level == "fatal" }}
console => error

{{ else if .log_level == "error" }}
console => error

{{ else if .log_level == "warning" }}
console => warning,error

{{ else if .log_level == "notice" }}
console => notice,warning,error

{{ else if .log_level == "info" }}
console => notice,warning,error,verbose

{{ else if .log_level == "debug" }}
console => notice,warning,error,verbose,debug

{{ else if .log_level == "trace" }}
console => notice,warning,error,verbose,debug,dtmf,fax

{{ else if .log_level == "all" }}
console => notice,warning,error,debug,verbose,dtmf,fax