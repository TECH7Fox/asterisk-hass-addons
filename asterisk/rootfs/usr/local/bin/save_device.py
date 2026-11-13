#!/usr/bin/env python3
"""Manage custom PJSIP endpoints in pjsip_custom.conf for the Asterisk Web UI."""

import os
import re
import subprocess
import sys

CUSTOM_PJSIP_PATH = "/config/asterisk/custom/pjsip_custom.conf"
ETC_PJSIP_PATH = "/etc/asterisk/pjsip_custom.conf"
ALLOWED_TYPES = {"sip", "webrtc", "tls", "doorbell"}
ALLOWED_TRANSPORTS = {
    "",
    "transport-udp",
    "transport-tcp",
    "transport-tls",
    "transport-wss",
}


def validate_ext(ext: str) -> str:
    """Validate and return a safe PJSIP extension identifier."""
    cleaned = ext.strip()
    if not re.fullmatch(r"[A-Za-z0-9_-]{1,32}", cleaned):
        raise ValueError(f"Invalid extension identifier: {ext!r}")
    return cleaned


def sanitize_display_name(name: str, fallback: str) -> str:
    """Sanitize display name for safe use in Asterisk INI comments and callerid."""
    cleaned = re.sub(r'["\r\n;]', "", name).strip()
    return cleaned or fallback


def sanitize_secret(secret: str) -> str:
    """Validate SIP secret does not contain newlines or control characters."""
    cleaned = re.sub(r"[\r\n\x00-\x1f]", "", secret).strip()
    if not cleaned:
        raise ValueError("SIP secret cannot be empty")
    return cleaned


def normalize_codecs(codecs: str) -> str:
    """Normalize and validate comma-separated Asterisk codec names."""
    cleaned = re.sub(r"\s+", "", codecs).lower()
    if not cleaned:
        return "opus,ulaw,alaw,g722"
    if not re.fullmatch(r"[a-z0-9_]+(?:,[a-z0-9_]+)*", cleaned):
        raise ValueError(f"Invalid codec list: {codecs!r}")
    return cleaned


def resolve_target_file() -> str:
    """Resolve persistent pjsip_custom.conf path and ensure /etc/asterisk symlink."""
    custom_dir = os.path.dirname(CUSTOM_PJSIP_PATH)
    if os.path.isdir("/config/asterisk") or os.path.exists(CUSTOM_PJSIP_PATH):
        os.makedirs(custom_dir, exist_ok=True)
        if not os.path.exists(CUSTOM_PJSIP_PATH):
            seed = "; Place your custom extensions here\n"
            if os.path.exists(ETC_PJSIP_PATH) and not os.path.islink(ETC_PJSIP_PATH):
                with open(ETC_PJSIP_PATH, "r", encoding="utf-8") as src:
                    seed = src.read()
            with open(CUSTOM_PJSIP_PATH, "w", encoding="utf-8") as dst:
                dst.write(seed)
        if os.path.isdir(os.path.dirname(ETC_PJSIP_PATH)):
            if not os.path.islink(ETC_PJSIP_PATH) or os.readlink(ETC_PJSIP_PATH) != CUSTOM_PJSIP_PATH:
                try:
                    if os.path.lexists(ETC_PJSIP_PATH):
                        os.remove(ETC_PJSIP_PATH)
                    os.symlink(CUSTOM_PJSIP_PATH, ETC_PJSIP_PATH)
                except OSError:
                    pass
        return CUSTOM_PJSIP_PATH
    return ETC_PJSIP_PATH


def remove_endpoint_from_ini(content: str, ext: str) -> str:
    """Remove existing sections and managed banner comments for an extension."""
    target_sections = {ext, f"{ext}-auth", f"{ext}-aor"}
    lines = content.splitlines()
    new_lines = []
    in_ext_section = False
    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()
        sec = re.match(r"^\[([^\]\(\)]+)(?:\([^\)]*\))?\]", stripped)
        if sec:
            section_name = sec.group(1).strip()
            if section_name in target_sections:
                in_ext_section = True
                i += 1
                continue
            in_ext_section = False
        if in_ext_section:
            i += 1
            continue
        if (
            stripped.startswith("; ---")
            and i + 1 < len(lines)
            and f"Endpoint {ext} " in lines[i + 1]
        ):
            i += 2
            if i < len(lines) and lines[i].strip().startswith("; ---"):
                i += 1
            continue
        new_lines.append(line)
        i += 1
    return "\n".join(new_lines).strip()


def reload_pjsip(delete_ext: str | None = None) -> None:
    """Reload Asterisk PJSIP configuration and optionally purge active state."""
    try:
        if delete_ext:
            subprocess.run(
                ["asterisk", "-rx", f"database deltree registrar contact/{delete_ext}"],
                check=False,
            )
            subprocess.run(
                ["asterisk", "-rx", f"channel request hangup PJSIP/{delete_ext}"],
                check=False,
            )
        subprocess.run(["asterisk", "-rx", "pjsip reload"], check=True)
        print("PJSIP reloaded successfully.")
    except Exception as exc:
        print(f"Notice: Asterisk reload call returned: {exc}")


def perform_delete(ext: str) -> None:
    """Delete an extension from pjsip_custom.conf and reload PJSIP."""
    ext = validate_ext(ext)
    target_file = resolve_target_file()

    if os.path.exists(target_file):
        with open(target_file, "r", encoding="utf-8") as f:
            content = f.read()
        new_content = remove_endpoint_from_ini(content, ext)
        with open(target_file, "w", encoding="utf-8") as f:
            f.write((new_content + "\n") if new_content else "")
        print(f"Successfully purged endpoint {ext} from {target_file}")

    reload_pjsip(delete_ext=ext)


def perform_save(
    ext: str,
    name: str,
    secret: str,
    dev_type: str,
    codecs: str,
    transport: str,
) -> None:
    """Create or update a PJSIP endpoint stanza in pjsip_custom.conf."""
    ext = validate_ext(ext)
    safe_name = sanitize_display_name(name, f"Device {ext}")
    safe_secret = sanitize_secret(secret)
    dev_type = dev_type.strip().lower()
    if dev_type not in ALLOWED_TYPES:
        raise ValueError(f"Unsupported device type: {dev_type!r}")
    safe_codecs = normalize_codecs(codecs)
    transport = transport.strip()
    if transport not in ALLOWED_TRANSPORTS:
        raise ValueError(f"Unsupported transport: {transport!r}")

    if not transport:
        if dev_type == "webrtc":
            transport = "transport-wss"
        elif dev_type == "tls":
            transport = "transport-tls"
        else:
            transport = "transport-udp"

    target_file = resolve_target_file()
    content = ""
    if os.path.exists(target_file):
        with open(target_file, "r", encoding="utf-8") as f:
            content = f.read()

    content = remove_endpoint_from_ini(content, ext)

    is_webrtc = "yes" if dev_type == "webrtc" else "no"
    media_enc = (
        "dtls" if dev_type == "webrtc" else ("sdes" if dev_type == "tls" else "no")
    )
    use_avpf = "yes" if dev_type == "webrtc" else "no"
    ice = "yes" if dev_type == "webrtc" else "no"

    transport_line = f"transport={transport}\n" if transport else ""
    stanza = f"""
; -------------------------------------------------------------
; Endpoint {ext} ({safe_name}) - Managed via Web UI
; -------------------------------------------------------------
[{ext}-auth]
type=auth
auth_type=userpass
username={ext}
password={safe_secret}

[{ext}-aor]
type=aor
max_contacts=6
remove_existing=yes
remove_unavailable=yes
qualify_frequency=60

[{ext}]
type=endpoint
context=default
disallow=all
allow={safe_codecs}
{transport_line}direct_media=no
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
aors={ext}-aor
auth={ext}-auth
callerid="{safe_name}" <{ext}>
"""
    parts = [part for part in (content.strip(), stanza.strip()) if part]
    new_content = "\n\n".join(parts) + "\n"

    with open(target_file, "w", encoding="utf-8") as f:
        f.write(new_content)

    print(f"Successfully wrote endpoint {ext} to {target_file}")
    reload_pjsip()


def main() -> None:
    """CLI entrypoint for saving or deleting Web UI PJSIP endpoints."""
    if len(sys.argv) >= 2 and sys.argv[1] in ("--delete", "-d", "delete"):
        if len(sys.argv) < 3:
            print("Usage: save_device.py --delete <ext>")
            sys.exit(1)
        perform_delete(sys.argv[2])
        return

    if len(sys.argv) >= 3 and sys.argv[2].upper() == "DELETE":
        perform_delete(sys.argv[1])
        return

    if len(sys.argv) < 5:
        print("Usage: save_device.py <ext> <name> <secret> <type> [codecs] [transport]")
        print("   or: save_device.py --delete <ext>")
        sys.exit(1)

    codecs = sys.argv[5] if len(sys.argv) > 5 else "opus,ulaw,alaw,g722"
    transport = sys.argv[6] if len(sys.argv) > 6 else ""
    perform_save(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], codecs, transport)


if __name__ == "__main__":
    main()
