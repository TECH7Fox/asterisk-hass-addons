[default]
host = 127.0.0.1
port = {{ .port }}
password = {{ .password }}
mbox_path = /var/spool/asterisk/voicemail/default/{{ .extension }}/
cache_file = /var/spool/asterisk/transcription.cache
google_key = {{ .api_key }}

# https://github.com/PhracturedBlue/asterisk_mbox_server