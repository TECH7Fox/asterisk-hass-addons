<!-- https://developers.home-assistant.io/docs/add-ons/presentation#keeping-a-changelog -->

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
