# Home Assistant Add-on: Asterisk

## Requirements

1. The certificate to your registered domain should already be created via the [Duck DNS](https://github.com/home-assistant/hassio-addons/tree/master/duckdns) or [Let's Encrypt](https://github.com/home-assistant/hassio-addons/tree/master/letsencrypt) add-on or another method. Make sure that the certificate files exist in the `/ssl` directory.

## Installation

Follow these steps to get the add-on installed on your system:

1. Make sure the [requirements](#Requirements) are met.
1. Navigate in your Home Assistant frontend to **_Supervisor_** -> **_Add-on Store_**.
2. Click the 3-dots menu at upper right **_..._** > **_Repositories_** and add this repository's URL: <https://github.com/TECH7Fox/Asterisk-add-on>
3. Scroll down the page to find the new repository, and click the new add-on named **_Asterisk_**.
4. Click **_INSTALL_** button.

## Configuration

**Note**: _Remember to restart the add-on when the configuration is changed._

Example add-on configuration:

```yaml
ami_password: my-password-of-choice
auto_add: true
certfile: fullchain.pem
keyfile: privkey.pem
ip: 192.168.0.1
```

**Note**: _This is just an example, don't copy and past it! Create your own!_

### Option: `ami_password`

The AMI password that will be used for the `admin` user. You can use any password that you want. When configuring the [Asterisk integration](https://github.com/TECH7Fox/Asterisk-integration), you should use `admin` as _username_ and this password as _password_.

### Option: `auto_add`

Enables/Disables the automatic creation of extensions for every [person](https://www.home-assistant.io/integrations/person/) registered in Home Assistant. They will have their number/username auto-generated starting from 100, while their password will be `1234` (currently hardcoded).

### Option: `certfile`

The certificate file to use for SSL.

**Note**: _The file MUST be stored in `/ssl/`, which is the default_

### Option: `keyfile`

The private key file to use for SSL.

**Note**: _The file MUST be stored in `/ssl/`, which is the default_

### Option: `ip`

HA server ip. (Only this IP will be allowed to connect)
