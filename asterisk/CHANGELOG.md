<!-- https://developers.home-assistant.io/docs/add-ons/presentation#keeping-a-changelog -->

# Changelog

## 2.4.0

- Add `chan_sip` (disabled by default) for Dahua VTO compatibility (by @bdherouville)

### Breaking changes

**Delete the old `sip.conf` and `modules.conf`.** This disables `chan_sip` by default and sets it on another port to prevent conflicts with `pjsip`.

## 2.3.5

- Upgrade Asterisk from 20.0.1 to 20.1.0 (by @felipecrs)
- Fix tmp dir for googletts and speech-recog (by @felipecrs)
  - Now they use `/data/tmp` instead of `tmp`, which is retained between restarts (but deleted upon uninstall) for add-ons.
- Refactor the installation of all patches for easier maintenance (by @felipecrs)

## 2.3.4

- Upgrade Asterisk from 18.15.0 to 20.0.1 (by @felipecrs)
- Upgrade addon-debian-base from 6.1.3 to 6.2.0 (by @felipecrs)

## 2.3.3

- Fix add-on failing to start sometimes (by @felipecrs)
- Upgrade Asterisk from 18.14.0 to 18.15.0 (by @felipecrs)
- Upgrade addon-debian-base from 6.1.1 to 6.1.3 (by @felipecrs)
- Upgrade asterisk-chan-dongle to [503dba8](https://github.com/wdoekes/asterisk-chan-dongle/commit/503dba87d726854b74b49e70679e64e6e86d5812) (by @felipecrs)

## 2.3.2

- Upgrade Asterisk from 18.12.1 to 18.14.0 (by @felipecrs)
- Upgrade addon-debian-base from 6.0.0 to 6.1.1 (by @felipecrs)

## 2.3.1

- Only include rtsp-sip for amd64 and i386 (by @TECH7Fox)

## 2.3.0

- Add php (by @TECH7Fox)
- Add rtsp-sip (by @TECH7Fox)
- Update builder and linter (by @felipecrs)

## 2.2.0

- Add pt-BR translations (by @LeandroIssa)
- Upgrade addon-base from 5.3.0 to 6.0.0 (by @felipecrs)
- Upgrade Asterisk from 18.10.1 to 18.12.1 (by @felipecrs)

## 2.1.5

- Fix domain bug that makes the WS contacts unreachable (by @TECH7Fox)

## 2.1.4

- Increase maximum possible number of SDP formats (#140) (by @nanosonde)

## 2.1.3

- Fix TLS transport
- Set NAT settings
- Include default STUN server

## 2.1.2

- Fix timezone
- Disable qualify for the generated pjsip extensions, because it wasn't used and caused problems

## 2.1.1

- Do not load chan-dongle by default (because it seems to cause lots of errors and warnings when there is no dongle attached)
  - You have to delete the `/config/asterisk/modules.conf` file so that the new one which
    has disabled chan-dongle can be created.

## 2.1.0

- Add [asterisk-chan-dongle](https://github.com/wdoekes/asterisk-chan-dongle)
- Add [asterisk-googletts](https://github.com/zaf/asterisk-googletts)
- Add [asterisk-speech-recog](https://github.com/zaf/asterisk-speech-recog)
- Run Asterisk as root (instead of as asterisk), this is requires so that chan-dongle can properly communicate with the dongle
- Tidy up some minor things

More information at #124.

## 2.0.2

- Fix Asterisk never starting after starting the addon (again, but for a different reason this time)

## 2.0.1

- Fix Asterisk never starting after starting the addon, which started to happen after [v2.0.0](#200) (issue #127, pr #128)

## 2.0.0

- Change base from Alpine to Debian (#116) (by @nanosonde)
  - Addon size has been considerable increased
- Upgrade Asterisk to 18.1.0 (#116) (by @nanosonde)
  - Now we build it from source, so we can always use the latest version and have more control about it
- Migrate from `chan_sip` to `res_pjsip`  (#112) (by @nanosonde)
  - This is a breaking change. Check below the upgrade guide.

Lots of issues were fixed by the above.

### Upgrade guide

It's strongly recommended to erase your existing Asterisk configuration before upgrading.

1. Move any customization you have done in `/config/asterisk/` to somewhere else.
2. Delete the `/config/asterisk` folder.
3. Restore your customizations to the `/config/asterisk` folder if you have any.
4. Make sure to convert your extensions from `chan_sip` to `res_pjsip` if you have any.

Then, you can go ahead and upgrade. Next time you start the addon, it will recreate the files at `/config/asterisk`.

## 1.3.3

- Include hint settings and add busylevel to auto generated extensions.

## 1.3.2

- Fix verbose and debug log levels

## 1.3.1

- Add `log_level` option

## 1.3.0

- Remove the initial Ingress support added in 1.2.0.
  - Ingress will not be needed to make the integration and the card work without having to export additional ports or configuring additional reverse proxies (details [here](https://github.com/dermotduffy/frigate-hass-card/issues/331#issuecomment-1043671490)).
- Remove the option to disable SSL (#98)
  - Disabling SSL causes the HA-SIP card not to work anymore.
- Add an option to automatically generate a self-signed certificate (#98)
  - So that, users running Asterisk behind a reverse proxy do not need to bother about managing their own certificate to be used by Asterisk. You can directly proxy `https://<ha-ip>:8089`.

## 1.2.1

- Disable WS protocol wrongly introduced in 1.2.0 which caused issues

## 1.2.0

- Add an option to disable SSL (#66)
  - Useful for setting up Asterisk to work behind a reverse proxy like NGINX. Here is one example on how to configure NGINX to proxy the Asterisk WebSockets interface: https://warlord0blog.wordpress.com/2020/04/16/asterisk-webrtc/
  - PS: This was not tested, so any feedback is welcome.
- Add initial support for Ingress (#57)
  - Work is still required from other components like the integration and the card to effectively be able to use it.
  - Note that the WebUI shown in the addon page is not a GUI page, but rather the WebSocket connection needed by SIP.JS to connect to the SIP server.
- Fix mailbox server not working (#92)
- Disable docker builtin init, to prevent multiple init systems as we already have S6 Overlay (#89)

## 1.1.5

- Fix permission denied error in discovery service (#85)

## 1.1.4

- Send out discovery information.

## 1.1.3

- Add `host` and `port` to discovery.

## 1.1.2

- Optimize when mailbox service is disabled [#80](https://github.com/TECH7Fox/asterisk-hass-addons/pull/80)

## 1.1.1

- Fix translations

## 1.1.0

- Add mailbox server [#68](https://github.com/TECH7Fox/asterisk-hass-addons/pull/68). To use with the Asterisk Mailbox Integration.
- Add discovery for the [Asterisk Integration](https://github.com/TECH7Fox/Asterisk-integration).
- Allow to customize `logging.conf`.

## 1.0.0

- Use parking instead of conference.
- Remove default passwords.
- Update config and docs.

## 0.3.4

- Add default conference room [#54](https://github.com/TECH7Fox/asterisk-hass-addons/pull/54). Now you can join a conference room via 444 (for default user) or 555 (for admin user). This is useful for things like doorbells.
- Add music-on-hold. (moh)

## 0.3.3

- Add video support [#39](https://github.com/TECH7Fox/asterisk-hass-addons/pull/39). This feature comes disabled by default as otherwise the SIP Lovelace Card does not work in the companion app.
- Fix AMI permit. Now use `localhost` as host in the Asterisk integration.
- Add auto_add_secret option [#50](https://github.com/TECH7Fox/asterisk-hass-addons/pull/50). This option is to prevent having a default secret for the auto-added extensions.

## 0.3.2

- Allow custom configs using `/config/asterisk/sip_custom.conf`
- Fix `_displayName` errors from SIP Lovelace Card

## 0.3.1

- Use prebuilt images for faster installation
- Use S6 Overlay to manage the Asterisk service

## 0.3.0 and below

Check the commit history.
