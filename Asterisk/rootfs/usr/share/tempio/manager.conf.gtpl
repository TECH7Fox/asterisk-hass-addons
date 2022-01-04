[general]
enabled = yes
port = 5038
bindaddr = 0.0.0.0
displayconnects = yes
[admin]
secret = {{ .AMI_PASSWORD }}
deny = 0.0.0.0/0.0.0.0
permit = {{ .HA_IP }}/255.255.255.254
read = system,call,log,verbose,command,agent,user,config,command,dtmf,reporting,cdr,dialplan,originate,message
write = system,call,log,verbose,command,agent,user,config,command,dtmf,reporting,cdr,dialplan,originate,message
writetimeout = 5000