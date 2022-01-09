upstream asterisk {
  server 127.0.0.1:8088;
}
server {
  listen {{ .ingress_port }};
  allow 172.30.32.2;
  deny all;
  location /ws {
    proxy_buffers 8 32k;
    proxy_buffer_size 64k;
    proxy_pass http://asterisk/ws;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header Host $http_host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_read_timeout 999999999;
  }
}