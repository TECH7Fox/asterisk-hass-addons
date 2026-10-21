#!/usr/bin/env python3
import sys
import os
import re
import subprocess

def remove_endpoint_from_ini(content, ext):
    lines = content.splitlines()
    new_lines = []
    in_ext_section = False
    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()
        sec = re.match(r"^\[([^\]\(\)]+)(?:\([^\)]*\))?\]", stripped)
        if sec:
            if sec.group(1).strip() == ext:
                in_ext_section = True
                i += 1
                continue
            else:
                in_ext_section = False
        if in_ext_section:
            i += 1
            continue
        if stripped.startswith("; ---") and i + 1 < len(lines) and f"Endpoint {ext} " in lines[i+1]:
            i += 2
            if i < len(lines) and lines[i].strip().startswith("; ---"):
                i += 1
            continue
        new_lines.append(line)
        i += 1
    return "\n".join(new_lines).strip()

def perform_delete(ext):
    candidates = [
        "/config/asterisk/custom/pjsip_custom.conf",
        "/etc/asterisk/pjsip_custom.conf"
    ]
    target_file = None
    for c in candidates:
        if os.path.exists(c):
            target_file = c
            break

    if not target_file:
        target_file = "/config/asterisk/custom/pjsip_custom.conf"

    if os.path.exists(target_file):
        with open(target_file, "r") as f:
            content = f.read()
        new_content = remove_endpoint_from_ini(content, ext)
        with open(target_file, "w") as f:
            f.write(new_content.strip() + "\n")
        print(f"Successfully purged endpoint {ext} from {target_file}")

    try:
        subprocess.run(["asterisk", "-rx", f"database deltree registrar contact/{ext}"], check=False)
        subprocess.run(["asterisk", "-rx", f"channel request hangup PJSIP/{ext}"], check=False)
        subprocess.run(["asterisk", "-rx", "pjsip reload"], check=True)
        print("PJSIP reloaded successfully.")
    except Exception as e:
        print(f"Notice: Asterisk reload call returned: {e}")

def main():
    if len(sys.argv) >= 2 and sys.argv[1] in ("--delete", "-d", "delete"):
        if len(sys.argv) < 3:
            print("Usage: save_device.py --delete <ext>")
            sys.exit(1)
        ext = sys.argv[2].strip()
        perform_delete(ext)
        return

    if len(sys.argv) >= 3 and sys.argv[2].upper() == "DELETE":
        ext = sys.argv[1].strip()
        perform_delete(ext)
        return

    if len(sys.argv) < 5:
        print("Usage: save_device.py <ext> <name> <secret> <type> [codecs] [transport]")
        print("   or: save_device.py --delete <ext>")
        sys.exit(1)

    ext = sys.argv[1].strip()
    name = sys.argv[2].strip()
    secret = sys.argv[3].strip()
    dev_type = sys.argv[4].strip().lower()
    codecs = sys.argv[5].strip() if len(sys.argv) > 5 and sys.argv[5].strip() else "opus,ulaw,alaw,g722"
    transport = sys.argv[6].strip() if len(sys.argv) > 6 and sys.argv[6].strip() else ""

    if not transport:
        if dev_type == "webrtc":
            transport = "transport-wss"
        elif dev_type == "tls":
            transport = "transport-tls"
        else:
            transport = "transport-udp"

    candidates = [
        "/config/asterisk/custom/pjsip_custom.conf",
        "/etc/asterisk/pjsip_custom.conf"
    ]
    target_file = None
    for c in candidates:
        if os.path.exists(c):
            target_file = c
            break

    if not target_file:
        target_file = "/config/asterisk/custom/pjsip_custom.conf"

    content = ""
    if os.path.exists(target_file):
        with open(target_file, "r") as f:
            content = f.read()

    content = remove_endpoint_from_ini(content, ext)

    is_webrtc = "yes" if dev_type == "webrtc" else "no"
    media_enc = "dtls" if dev_type == "webrtc" else ("sdes" if dev_type == "tls" else "no")
    use_avpf = "yes" if dev_type == "webrtc" else "no"
    ice = "yes" if dev_type == "webrtc" else "no"

    stanza = f"""
; -------------------------------------------------------------
; Endpoint {ext} ({name}) - Managed via Web UI
; -------------------------------------------------------------
[{ext}](linphone-auth)
type=auth
auth_type=userpass
username={ext}
password={secret}

[{ext}](linphone-aor)
type=aor
max_contacts=3
remove_existing=yes
remove_unavailable=no
qualify_frequency=0

[{ext}](linphone-endpoint)
type=endpoint
context=default
disallow=all
allow={codecs}
allow=h264
{f"transport={transport}" if transport and dev_type != "sip" else ""}
direct_media=no
rtp_symmetric=yes
force_rport=yes
rewrite_contact=yes
from_domain=asterisk
device_state_busy_at=1
send_rpid=yes
send_pai=yes
webrtc={is_webrtc}
media_encryption={media_enc}
use_avpf={use_avpf}
ice_support={ice}
aors={ext}
auth={ext}
callerid="{name}" <{ext}>
"""
    new_content = content + "\n" + stanza.strip() + "\n"

    with open(target_file, "w") as f:
        f.write(new_content)

    print(f"Successfully wrote endpoint {ext} to {target_file}")

    try:
        subprocess.run(["asterisk", "-rx", "pjsip reload"], check=True)
        print("PJSIP reloaded successfully.")
    except Exception as e:
        print(f"Notice: Asterisk reload call returned: {e}")

if __name__ == "__main__":
    main()
