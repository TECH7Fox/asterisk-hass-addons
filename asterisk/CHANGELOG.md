<!-- https://developers.home-assistant.io/docs/add-ons/presentation#keeping-a-changelog -->

## 1.1.6

- Fix mailbox server

## 1.1.5

- Fix permission denied error in discovery service (#85)

## 1.1.4

- Send out discovery information.

## 1.1.3

- Add `host` and `port` to discovery.

## 1.1.2

- Optimize when mailbox service is disabled [#80](https://github.com/TECH7Fox/Asterisk-add-on/pull/80)

## 1.1.1

- Fix translations

## 1.1.0

- Add mailbox server [#68](https://github.com/TECH7Fox/Asterisk-add-on/pull/68). To use with the Asterisk Mailbox Integration.
- Add discovery for the [Asterisk Integration](https://github.com/TECH7Fox/Asterisk-integration).
- Allow to customize `logging.conf`.

## 1.0.0

- Use parking instead of conference.
- Remove default passwords.
- Update config and docs.

## 0.3.4

- Add default conference room [#54](https://github.com/TECH7Fox/Asterisk-add-on/pull/54). Now you can join a conference room via 444 (for default user) or 555 (for admin user). This is useful for things like doorbells.
- Add music-on-hold. (moh)

## 0.3.3

- Add video support [#39](https://github.com/TECH7Fox/Asterisk-add-on/pull/39). This feature comes disabled by default as otherwise the SIP Lovelace Card does not work in the companion app.
- Fix AMI permit. Now use `localhost` as host in the Asterisk integration.
- Add auto_add_secret option [#50](https://github.com/TECH7Fox/Asterisk-add-on/pull/50). This option is to prevent having a default secret for the auto-added extensions.

## 0.3.2

- Allow custom configs using `/config/asterisk/sip_custom.conf`
- Fix `_displayName` errors from SIP Lovelace Card

## 0.3.1

- Use prebuilt images for faster installation
- Use S6 Overlay to manage the Asterisk service

## 0.3.0 and below

Check the commit history.
