# Home Assistant Add-on: Asterisk

Asterisk is a free and open source framework for building communications applications.
Asterisk powers IP PBX systems, VoIP gateways, conference servers, and is used by SMBs, enterprises, call centers, carriers and governments worldwide.

## Installation

Follow these steps to get the add-on installed on your system:

1. Click here:

    [![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FTECH7Fox%2Fasterisk-hass-addons)

1. Scroll down the page to find the new repository, and click in the new add-on named **_Asterisk_**.
1. Click in the **_INSTALL_** button.

## Using

1. The certificate to your registered domain should already be created via the [Duck DNS](https://github.com/home-assistant/hassio-addons/tree/master/duckdns) or [Let's Encrypt](https://github.com/home-assistant/hassio-addons/tree/master/letsencrypt) add-on or another method. Make sure that the certificate files exist in the `/ssl/` directory.
2. Check the add-on configuration by going to the **_Configuration_** tab. You need to at least fill the _AMI Password_ and the _Auto add secret_ (if you leave _Auto add extensions_ enabled).
3. Start the add-on by clicking in the **_START_** button.

**Note**: _Remember to restart the add-on when the configuration is changed._

### Option: `ami_password`
Set's the password for the Asterisk Manager Interface, to connect to the [Asterisk integration](https://github.com/TECH7Fox/Asterisk-integration).

### Option: `video_support`
Enables video support for the auto generated extensions.

### Option: `auto_add`
Creates a extension for every [person](https://www.home-assistant.io/integrations/person/) registered in Home Assistant. They will have their number and username auto-generated starting from 100, with the `callerid` set to the person's name.

### Option: `auto_add_secret`
The secret for the auto generated extensions.

### Option: `generate_ssl_cert`
Enables/disables the generation of a self-signed certificate for use with the SSL interfaces (WSS and TLS).

### Option: `certfile`
The certificate file to use for SSL in your `/ssl/` folder, when `generate_ssl_cert` is disabled.

### Option: `keyfile`
The key file to use for SSL in your `/ssl/` folder, when `generate_ssl_cert` is disabled.

### Option: `mailbox_server`
Enables the mailbox server to send voicemails to the Asterisk mailbox integration.

### Option: `mailbox_port`
The port used by the mailbox server.

### Option: `mailbox_password`
The password for the mailbox server.

### Option: `mailbox_extension`
Which extension to get the voicemails from.

### Option: `api_key`
The API Key for speech-to-text.
You can get a key [here](https://cloud.google.com/speech-to-text). Google says it's free, but requires a billing account.

### Option: `log_level`
The log level to configure Asterisk to use. To know more about the existing presets, check [`logger.conf`](./rootfs/usr/share/tempio/logger.conf.gtpl).

## Configuring the [Asterisk integration](https://github.com/TECH7Fox/Asterisk-integration)

- **_Host_**: `localhost`
- **_Port_**: `5038`
- **_Username_**: `admin`
- **_Password_**: whatever you set in the AMI Password configuration

## Configuring the [SIP.js card](https://github.com/TECH7Fox/HA-SIP)

- **_Host_**: `localhost`
- **_Port_**: `8089`
- **_Video_**: `false` _Video is not working at the moment, this will be fixed soon. For now you could use the camera entity instead._

And add a extension. To see which extension every person has, you can look at `/config/asterisk/sip_default.conf`.

## Wiki
For more information, visit the [SIP-HASS docs](https://tech7fox.github.io/sip-hass-docs/).

## Troubleshoot
If you are having problems with the add-on, try deleting the `asterisk` folder located at `/config/` and restart the add-on. This will make sure you have the latest configuration files.
