# Home Assistant Add-on: Asterisk

Asterisk is a free and open source framework for building communications applications.
Asterisk powers IP PBX systems, VoIP gateways, conference servers, and is used by SMBs, enterprises, call centers, carriers and governments worldwide.

## Installation

Follow these steps to get the add-on installed on your system:

1. Click here:

   [![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FTECH7Fox%2Fasterisk-hass-addons)

1. Scroll down the page to find the new repository, and click in the new add-on named **_Asterisk_**.
1. Click in the **_INSTALL_** button.

Or you can also use it as a standalone docker container. See [4.0.0 release notes](./CHANGELOG.md#400) for more information.

## Using

1. The certificate to your registered domain should already be created via the [Duck DNS](https://github.com/home-assistant/hassio-addons/tree/master/duckdns) or [Let's Encrypt](https://github.com/home-assistant/hassio-addons/tree/master/letsencrypt) add-on or another method. Make sure that the certificate files exist in the `/ssl/` directory.
2. Check the add-on configuration by going to the **_Configuration_** tab. You need to at least fill the _AMI Password_ and the _Auto add secret_ (if you leave _Auto add extensions_ enabled).
3. Start the add-on by clicking in the **_START_** button.

## Configuring Asterisk

The add-on copies all the default Asterisk config files to `/addon_configs/b35499aa-asterisk/asterisk/default` on the add-on startup for your reference, and reads all customized config files from `/addon_configs/b35499aa-asterisk/asterisk/custom`.

For example, if you need to change something in the `/etc/asterisk/extensions.conf`, you can copy the reference `/addon_configs/b35499aa-asterisk/asterisk/default/extensions.conf` to `/addon_configs/b35499aa-asterisk/asterisk/custom/extensions.conf` and make your changes there.

The way how this works is through symbolic links: if there is a custom config file, a symbolic link is created on top of the default config file pointing to the custom config file. Have in mind that this is only applicable for files under the root of `/addon_configs/b35499aa-asterisk/asterisk/custom`. For example, the `/addon_configs/b35499aa-asterisk/asterisk/custom/subdir/file.conf` **will not** be linked to `/etc/asterisk/subdir/file.conf`. The same applies to files that starts with a dot, like `.gitignore`.

**Note**: _Remember to restart the add-on when the Asterisk configuration files are changed._

## Configuring the add-on

We expose some configuration options to simplify the setup of the Asterisk server inside of the add-on. See below for more information on each option we provide.

**Note**: _Remember to restart the add-on when the configuration is changed._

### Option: `ami_password`

Set's the password for the Asterisk Manager Interface, to connect to the [Asterisk integration](https://github.com/TECH7Fox/Asterisk-integration).

### Option: `auto_add`

Creates a extension for every [person](https://www.home-assistant.io/integrations/person/) registered in Home Assistant. They will have their number and username auto-generated starting from 100, with the `callerid` set to the person's name.

**This is enabled by default for add-on users but disabled by default for container users.**

### Option: `auto_add_secret`

The secret for the auto generated extensions, when `auto_add` is enabled.

### Option: `video_support`

Enables video support for the auto generated extensions, when `auto_add` is enabled.

### Option: `additional_sounds`

The additional sounds languages to download from <https://asterisksounds.org> on add-on startup, skipping when already downloaded. Example: pt-BR.

The sounds will be downloaded to `/media/asterisk`.

If you want the add-on to re-download the sounds, you can simply remove the folder from `/media/asterisk` and restart it.

### Option: `generate_ssl_cert`

Enables/disables the generation of a self-signed certificate for use with the SSL interfaces (WSS and TLS).

### Option: `certfile`

The certificate file to use for SSL in your `/ssl/` folder, when `generate_ssl_cert` is disabled. If an absolute path is provided, it will be used as-is.

### Option: `keyfile`

The key file to use for SSL in your `/ssl/` folder, when `generate_ssl_cert` is disabled. If an absolute path is provided, it will be used as-is.

### Option: `mailbox`

Enables the mailbox server to send voicemails to the Asterisk Mailbox integration.

### Option: `mailbox_port`

The port used by the mailbox server.

### Option: `mailbox_password`

The password for the mailbox server.

### Option: `mailbox_extension`

Which extension to get the voicemails from.

### Option: `mailbox_google_api_key`

The API Key for the speech-to-text used by Asterisk Mailbox.
You can get a key [here](https://cloud.google.com/speech-to-text). Google says it's free, but requires a billing account.

### Option: `log_level`

The log level to configure Asterisk to use. To know more about the existing presets, check [`logger.conf`](./rootfs/usr/share/tempio/logger.conf.gtpl).

## STDIN service

You can use the STDIN service to run any Asterisk CLI commands that you want. For example:

```yaml
service: hassio.addon_stdin
  data:
    addon: b35499aa_asterisk
    input: dialplan reload
```

**This is only possible when using as an add-on.**

## Startup script

If the add-on finds a script at `/addon_configs/b35499aa-asterisk/asterisk/startup.sh` it will run it before starting Asterisk. You can use this to install custom packages, dependancies, etc.

## Configuring the [Asterisk integration](https://github.com/TECH7Fox/Asterisk-integration)

- **_Host_**: `localhost` (when running as an add-on)
- **_Port_**: `5038`
- **_Username_**: `admin`
- **_Password_**: whatever you set in the `ami_password` configuration

## Configuring the [SIP.js card](https://github.com/TECH7Fox/HA-SIP)

- **_Host_**: `localhost` (when running as an add-on)
- **_Port_**: `8089`
- **_Video_**: `false` _Video is not working at the moment, this will be fixed soon. For now you could use the camera entity instead._

And add a extension. To see which extension every person has, you can look at `/addon_configs/b35499aa-asterisk/asterisk/default/sip_default.conf`.

## Wiki

For more information, visit the [SIP-HASS docs](https://tech7fox.github.io/sip-hass-docs/).
