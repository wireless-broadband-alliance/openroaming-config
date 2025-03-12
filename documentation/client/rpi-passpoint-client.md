# Configuring a Raspberry PI to be a Wi-Fi Host (End-User device) enabled for Passpoint (and OpenRoaming)

![Raspberry PI with USB dongle](https://github.com/wireless-broadband-alliance/openroaming-config/blob/main/assets/RPI_Passpoint.png?raw=true)

## Introduction

This guide is to enable a **Raspberry PI** to be used as a Passpoint/OpenRoaming **End-User device**.

- Guides on how to enable OpenRoaming on an OpenWrt End-User device are available [here](https://github.com/hgot07/openwrt-passpoint).
- A guide on how to enable OpenRoaming Access Point/RadSec proxy on a MikroTik is available [here](https://wkumari.dev/2023/10/16/mikrotik-openroaming).

## Raspberry PI Model and OS

This demo uses Raspberry Pi 4 Model B with kernel version v5.10. Download the image from [Raspberry Pi OS](https://downloads.raspberrypi.org/raspios_armhf/images/raspios_armhf-2021-03-25/) and write it to the SD-card.

## Wi-Fi Dongle

The onboard Wi-Fi from the Broadcom chip does not support IEEE 802.11u, so this demo uses a Realtek RTL8812 Wi-Fi Dongle, a TP-Link AC1300. Other dongles are listed [here](https://kalitut.com/rtl8812au-wifi-usb-adapter/).

## Update and Upgrade your Raspberry PI

```bash
sudo apt-get update --allow-releaseinfo-change
sudo apt-get upgrade
```

Grab yourself a cup of tea/coffee, then after the upgrade is complete, check your OS:

```bash
sudo reboot
uname -a
Linux raspberrypi 5.10.103-v7l+ #1529 SMP Tue Mar 8 12:24:00 GMT 2022 armv7l GNU/Linux
```

Check Wi-Fi USB dongle is detected:

```bash
lsusb
Bus 001 Device 003: ID 2357:0115 TP-Link
```

Confirm that wlan1 is not operational:

```bash
iwconfig
lo        no wireless extensions.
eth0      no wireless extensions.
wlan0     IEEE 802.11  ESSID:off/any
          Mode:Managed  Access Point: Not-Associated   Tx-Power=31 dBm
          Retry short limit:7   RTS thr:off   Fragment thr:off
          Power Management:on
```

## Install the Realtek 8812BU Driver

Follow the instructions [here](https://github.com/fastoe/RTL8812BU_for_Raspbian). Note that the demo uses kernel 5.10, so follow the resolution to the issue listed [here](https://github.com/fastoe/RTL8812BU_for_Raspbian/issues/8).

```bash
sudo apt install -y bc git dkms build-essential raspberrypi-kernel-headers
git clone -b v5.6.1 https://github.com/fastoe/RTL8812BU_for_Raspbian
cd RTL8812BU_for_Raspbian
make
sudo make install
sudo reboot
```

Confirm that wlan1 is now operational:

```bash
iwconfig
lo        no wireless extensions.
eth0      no wireless extensions.
wlan0     IEEE 802.11  ESSID:off/any
          Mode:Managed  Access Point: Not-Associated   Tx-Power=31 dBm
          Retry short limit:7   RTS thr:off   Fragment thr:off
          Power Management:on
wlan1     unassociated  Nickname:"<WIFI@REALTEK>"
          Mode:Managed  Frequency=2.412 GHz  Access Point: Not-Associated
          Sensitivity:0/0
          Retry:off   RTS thr:off   Fragment thr:off
          Power Management:off
          Link Quality:0  Signal level:0  Noise level:0
          Rx invalid nwid:0  Rx invalid crypt:0  Rx invalid frag:0
          Tx excessive retries:0  Invalid misc:0   Missed beacon:0
```

## Install WPA Supplicant

```bash
git clone git://w1.fi/hostap.git
cd hostap/wpa_supplicant/
```

Edit the default build configuration file:

```bash
sudo nano defconfig
```

Example edits are shown below:

| No. | Action        | Config Field                            |
|-----|---------------|-----------------------------------------|
| 1   | Uncomment out | `#CONFIG_DRIVER_NONE=y`                 |
| 2   | Uncomment out | `#CONFIG_EAP_PSK=y`                     |
| 3   | Uncomment out | `#CONFIG_WPS_ER=y`                      |
| 4   | Uncomment out | `#CONFIG_WPS_REG_DISABLE_OPEN=y`        |
| 5   | Uncomment out | `#CONFIG_EAP_EKE=y`                     |
| 6   | Uncomment out | `#CONFIG_HT_OVERRIDES=y`                |
| 7   | Uncomment out | `#CONFIG_VHT_OVERRIDES=y`               |
| 8   | Uncomment out | `#CONFIG_READLINE=y`                    |
| 9   | Uncomment out | `#CONFIG_MAIN=main`                     |
| 10  | Uncomment out | `#CONFIG_OS=unix`                       |
| 11  | Uncomment out | `#CONFIG_L2_PACKET=linux`               |
| 12  | Add in        | `CONFIG_IEEE80211W=y`                   |
| 13  | Uncomment out | `#CONFIG_TLS=openssl`                   |
| 14  | Uncomment out | `#CONFIG_TLSV11=y`                      |
| 15  | Uncomment out | `#CONFIG_TLSV12=y`                      |
| 16  | Comment out   | `CONFIG_DEBUG_FILE=y`                   |
| 17  | Comment out   | `CONFIG_DEBUG_SYSLOG=y`                 |
| 18  | Uncomment out | `#CONFIG_DELAYED_MIC_ERROR_REPORT=y`    |
| 19  | Uncomment out | `#CONFIG_WNM=y`                         |
| 20  | Comment out   | `CONFIG_AP=y`                           |
| 21  | Comment out   | `CONFIG_P2P=y`                          |
| 22  | Comment out   | `CONFIG_WIFI_DISPLAY=y`                 |
| 23  | Uncomment out | `#CONFIG_AUTOSCAN_EXPONENTIAL=y`        |
| 24  | Uncomment out | `#CONFIG_AUTOSCAN_PERIODIC=y`           |
| 25  | Add in        | `CONFIG_BGSCAN_SIMPLE=y`                |
| 26  | Add in        | `CONFIG_IBSS_RSN=y`                     |

Now copy the edited defconfig to .config:

```bash
cp defconfig .config
```

Install wpa_supplicant dependencies:

```bash
sudo apt-get install build-essential libcurl4-openssl-dev libdbus-1-3 libdbus-1-dev libncurses5 libncurses5-dev libncursesw5 libnih1 libnih-dbus1 libnl-3-200 libnl-3-dev libnl-cli-3-200 libnl-cli-3-dev libnl-genl-3-200 libnl-genl-3-dev libnl-nf-3-200 libnl-nf-3-dev libnl-route-3-200 libnl-route-3-dev libreadline6 libreadline7 libreadline-dev libssl1.0.2 libssl-dev libssl1.1 libxml2-dev ncurses-bin readline-common zlib1g python python-dbg libncap-dev libpcap0.8-dev
```

And build wpa_supplicant:

```bash
cd hostap/wpa_supplicant/
make -j5
sudo make install
```

Create a configuration file:

```bash
cd hostap/wpa_supplicant/
sudo nano config.conf
```

And add this line:

```plaintext
ctrl_interface=DIR=/var/run/wpa_supplicant1 GROUP=netdev
```

## Configure WPA_Supplicant on WLAN Dongle

Check that the PI's default wpa_supplicant isn't running on wlan1:

```bash
ps auxw | grep wpa_supplicant
root       571  0.0  0.0  11092  4044 ?        Ss   17:02   0:00 wpa_supplicant -B -c/etc/wpa_supplicant/wpa_supplicant.conf -iwlan0 -Dnl80211,wext
root      1589  0.0  0.0   9948  3164 pts/0    S+   17:07   0:00 wpa_supplicant -B -c/etc/wpa_supplicant/wpa_supplicant.conf -iwlan1 -Dnl80211,wext
```

If the default /etc/wpa_supplicant is running (as shown above), kill the wlan1 process.

### Start wpa_supplicant on the dongle

```bash
cd hostap/wpa_supplicant/
sudo ./wpa_supplicant -cconfig.conf -iwlan1 -Dnl80211,wext
```

And in a separate window, start the CLI

:

```bash
cd hostap/wpa_supplicant/
./wpa_cli -i wlan1 -p /var/run/wpa_supplicant1
```

Use the interactive CLI to view the HS2.0 networks around you:

```plaintext
> scan
OK
<3>CTRL-EVENT-SCAN-STARTED
<3>CTRL-EVENT-SCAN-RESULTS
<3>WPS-AP-AVAILABLE-AUTH
<3>Removed BSSID 96:15:54:50:0f:1c from ignore list (clear)
<3>CTRL-EVENT-NETWORK-NOT-FOUND
> scan_results
bssid / frequency / signal level / flags / ssid
96:15:54:50:0f:1c 5180 -44 [WPA2-EAP-CCMP][ESS][P2P][HS20] vodafone
ae:15:54:50:0f:1c 5180 -47 [WPA2-EAP-CCMP][ESS][P2P][HS20] OR-Free-Bronze
8a:15:54:50:0f:1c 5180 -47 [WPA2-PSK-CCMP][ESS] Floor1-3
90:21:06:f5:e7:4d 5180 -61 [WPA2-PSK-CCMP][WPS-AUTH][ESS] SKYE26E7
78:3e:53:75:76:33 5180 -66 [WPA2-PSK-CCMP][WPS-AUTH][ESS] SKYE26E7
90:21:06:52:05:4a 2437 -38 [WPA2-PSK-CCMP][WPS][ESS] SKYE26E7
ae:15:44:50:0f:1c 2412 -40 [WPA2-EAP-CCMP][ESS][P2P][HS20] OR-Free-Bronze
96:15:44:50:0f:1c 2412 -41 [WPA2-EAP-CCMP][ESS][P2P][HS20] vodafone
90:21:06:f5:e7:4a 2412 -59 [WPA2-PSK-CCMP][WPS][ESS] SKYE26E7
78:3e:53:75:76:36 2462 -64 [WPA2-PSK-CCMP][WPS][ESS] SKYE26E7
24:a7:dc:af:95:0a 2412 -66 [WPA2-PSK-CCMP][WPS][ESS] SKYE26E7
78:3e:53:a8:a7:36 2462 -72 [WPA2-PSK-CCMP][WPS][ESS] SKYE26E7
78:3e:53:bd:0c:56 2437 -75 [WPA2-PSK-CCMP][WPS][ESS] SKYE26E7
>
```

## Using WPA_Supplicant Interactive CLI to Query for RCOIs

In the interactive CLI, you can get ANQP elements.

From IEEE 802.11, a selection of ANQP Information IDs are:

| Information Name                  | ANQP ID |
|-----------------------------------|---------|
| Roaming Consortium List           | 261     |
| NAI Realm List                    | 263     |
| 3GPP Cellular Network Information | 264     |
| Domain Name List                  | 268     |

Note, you can switch to debug mode and see details of the ANQP queries. In the terminal:

```bash
./wpa_cli -i wlan1 -p /var/run/wpa_supplicant1 log_level debug
```

Now use the interactive CLI to send the ANQP Query:

```plaintext
> anqp_get ae:15:44:50:0f:1c 261
OK
<3>GAS-QUERY-START addr=ae:15:44:50:0f:1c dialog_token=42 freq=2412
<3>GAS-QUERY-DONE addr=ae:15:44:50:0f:1c dialog_token=42 freq=2412 status_code=0 result=SUCCESS
<3>RX-ANQP ae:15:44:50:0f:1c Roaming Consortium list
<3>ANQP-QUERY-DONE addr=ae:15:44:50:0f:1c result=SUCCESS
>
```

The RCOIs can be viewed in the debug window:

```plaintext
Control interface recv command from: /tmp/wpa_ctrl_1790-1\x00
wlan1: Control interface command 'ANQP_GET ae:15:44:50:0f:1c 261'
wlan1: ANQP: Query Request to ae:15:44:50:0f:1c for 1 id(s)
GAS: Use own MAC address as the transmitter address (no gas_rand_mac_adr set) (no driver rand capa
wlan1: GAS-QUERY-START addr=ae:15:44:50:0f:1c dialog_token=29 freq=2412
<skipped debug lines>
wlan1: Event RX_MGMT (18) received
wlan1: Received Action frame: SA=ae:15:44:50:0f:1c Category=4 DataLen=26 freq=2412 MHz
wlan1: GAS-QUERY-DONE addr=ae:15:44:50:0f:1c dialog_token=29 freq=2412 status_code=0 result=SUCCESS
Interworking: anqp_resp_cb dst=ae:15:44:50:0f:1c dialog_token=29 result=0 status_code=0
wlan1: RX-ANQP ae:15:44:50:0f:1c Roaming Consortium list
ANQP: Roaming Consortium - hexdump_ascii(len=10):
     03 00 40 96 05 5a 03 ba 00 00                     __@__Z____
wlan1: ANQP-QUERY-DONE addr=ae:15:44:50:0f:1c result=SUCCESS
```

Which shows that 2 RCOIs have been returned, the first a 3 byte "00-40-96" and the second, a 5 byte "5a-03-ba-00-00".

## Checking Passpoint Based Automatic Network Selection

First remove any existing credentials:

```plaintext
> remove_cred all
OK
<3>CRED-REMOVED 0
```

Now check if any networks match for Passpoint automatic network selection:

```plaintext
> interworking_select
OK
<3>CTRL-EVENT-SCAN-STARTED
<3>Starting ANQP fetch for ae:15:54:50:0f:1c (HESSID 00:00:00:00:00:00)
<3>GAS-QUERY-START addr=ae:15:54:50:0f:1c dialog_token=175 freq=5180
<3>GAS-QUERY-DONE addr=ae:15:54:50:0f:1c dialog_token=175 freq=5180 status_code=0 result=SUCCESS
<3>RX-ANQP ae:15:54:50:0f:1c ANQP Capability list
<3>RX-HS20-ANQP ae:15:54:50:0f:1c HS Capability List
<3>ANQP-QUERY-DONE addr=ae:15:54:50:0f:1c result=SUCCESS
<skipped>
<3>Starting ANQP fetch for 96:15:44:50:0f:1c (HESSID 00:00:00:00:00:00)
<3>GAS-QUERY-START addr=96:15:44:50:0f:1c dialog_token=34 freq=2412
<3>GAS-QUERY-DONE addr=96:15:44:50:0f:1c dialog_token=34 freq=2412 status_code=0 result=SUCCESS
<3>RX-ANQP 96:15:44:50:0f:1c ANQP Capability list
<3>RX-HS20-ANQP 96:15:44:50:0f:1c HS Capability List
<3>ANQP-QUERY-DONE addr=96:15:44:50:0f:1c result=SUCCESS
<3>ANQP fetch completed
<3>INTERWORKING-NO-MATCH No network with matching credentials found
>
```

Indicating that there are no credentials matching the scanned networks.

## Configuring a Passpoint Credential

Use the CLI to add in an EAP credential:

```plaintext
> add_cred
0
<3>CRED-ADDED 0
> set_cred 0 realm "idp.openroaming.net"
OK
<3>CRED-MODIFIED 0 realm
> set_cred 0 username "test"
OK
<3>CRED-MODIFIED 0 username
> set_cred 0 password "test"
OK
<3>CRED-MODIFIED 0 password
> set_cred 0 eap TTLS
OK
<3>CRED-MOD

IFIED 0 eap
> set_cred 0 priority 1
OK
<3>CRED-MODIFIED 0 priority
```

The interworking_select command can be re-run to confirm the EAP credential does not trigger a match:

```plaintext
> interworking_select
OK
<3>CTRL-EVENT-SCAN-STARTED
<skipped>
<3>ANQP fetch completed
<3>INTERWORKING-NO-MATCH No network with matching credentials found
>
```

Now make the EAP credential into a Passpoint credential by adding an RCOI and re-run the interworking test:

```plaintext
> set_cred 0 roaming_consortiums "5a03ba0000"
OK
<3>CRED-MODIFIED 0 roaming_consortiums
> interworking_select
OK
<3>CTRL-EVENT-SCAN-STARTED
<3>Starting ANQP fetch for ae:15:54:50:0f:1c (HESSID 00:00:00:00:00:00)
<3>GAS-QUERY-START addr=ae:15:54:50:0f:1c dialog_token=215 freq=5180
<3>GAS-QUERY-DONE addr=ae:15:54:50:0f:1c dialog_token=215 freq=5180 status_code=0 result=SUCCESS
<3>RX-ANQP ae:15:54:50:0f:1c ANQP Capability list
<3>RX-HS20-ANQP ae:15:54:50:0f:1c HS Capability List
<3>ANQP-QUERY-DONE addr=ae:15:54:50:0f:1c result=SUCCESS
<3>Starting ANQP fetch for 96:15:54:50:0f:1c (HESSID 00:00:00:00:00:00)
<3>GAS-QUERY-START addr=96:15:54:50:0f:1c dialog_token=195 freq=5180
<3>GAS-QUERY-DONE addr=96:15:54:50:0f:1c dialog_token=195 freq=5180 status_code=0 result=SUCCESS
<3>RX-ANQP 96:15:54:50:0f:1c ANQP Capability list
<3>RX-HS20-ANQP 96:15:54:50:0f:1c HS Capability List
<3>ANQP-QUERY-DONE addr=96:15:54:50:0f:1c result=SUCCESS
<3>Starting ANQP fetch for 96:15:44:50:0f:1c (HESSID 00:00:00:00:00:00)
<3>GAS-QUERY-START addr=96:15:44:50:0f:1c dialog_token=76 freq=2412
<3>GAS-QUERY-DONE addr=96:15:44:50:0f:1c dialog_token=76 freq=2412 status_code=0 result=SUCCESS
<3>RX-ANQP 96:15:44:50:0f:1c ANQP Capability list
<3>RX-HS20-ANQP 96:15:44:50:0f:1c HS Capability List
<3>ANQP-QUERY-DONE addr=96:15:44:50:0f:1c result=SUCCESS
<3>Starting ANQP fetch for ae:15:44:50:0f:1c (HESSID 00:00:00:00:00:00)
<3>GAS-QUERY-START addr=ae:15:44:50:0f:1c dialog_token=243 freq=2412
<3>GAS-QUERY-DONE addr=ae:15:44:50:0f:1c dialog_token=243 freq=2412 status_code=0 result=SUCCESS
<3>RX-ANQP ae:15:44:50:0f:1c ANQP Capability list
<3>RX-HS20-ANQP ae:15:44:50:0f:1c HS Capability List
<3>ANQP-QUERY-DONE addr=ae:15:44:50:0f:1c result=SUCCESS
<3>ANQP fetch completed
<3>INTERWORKING-AP ae:15:54:50:0f:1c type=unknown id=0 priority=1 sp_priority=0
<3>INTERWORKING-AP 96:15:54:50:0f:1c type=unknown id=0 priority=1 sp_priority=0
<3>INTERWORKING-AP 96:15:44:50:0f:1c type=unknown id=0 priority=1 sp_priority=0
<3>INTERWORKING-AP ae:15:44:50:0f:1c type=unknown id=0 priority=1 sp_priority=0
>
```

This indicates that 4 BSSIDs are identified as matching the Passpoint profile. Importantly, no networks had to be configured on the PI, just a single Passpoint End-User credential.

<hr>

# Setting up EAP-TLS server

Configure EAP-TLS RADIUS server. It's recommended you use FreeRADIUS v2.3, so follow the instructions [here](https://networkradius.com/packages/#fr32-ubuntu).

## Set up CA, Server, and Client Certificates

On the RADIUS server, edit the configuration in the /certs folder. Edit the policy line:

```plaintext
- policy           = policy_match
+ policy           = policy_anything
```

Edit the ca.cnf, server.cnf, and client.cnf as you see fit. Example configurations are included in this post: [FreeRadius EAP-TLS configuration](https://wiki.alpinelinux.org/wiki/FreeRadius_EAP-TLS_configuration).

Run the script to generate the CA, Server, and Client certificates:

```bash
./bootstrap
```

Copy the client.key, client.pem, and ca.pem to a USB drive.

## Set up EAP-TLS certificates and trust anchor on the Raspberry PI

We are first going to use the integrated wlan0 to test EAP-TLS, before then using the certificate as a Passpoint credential.

Copy the client certificate and key to the PI:

```bash
cd /media/pi/<USB name>
sudo cp client.pem /etc/ssl/certs/client.pem
sudo cp client.key /etc/ssl/certs/client.key
```

Copy the CA certificate to the PI and add the CA to the trusted CA list. The CA.pem needs to be copied into two locations:

```bash
cd /media/pi/<USB name>
sudo cp ca.pem /etc/ssl/certs/ca.pem
sudo cp ca.pem /usr/local/share/ca-certificates/ca.crt
```

Now add the CA onto the ca-certificates.crt based list of trusted CAs:

```bash
sudo apt-get install -y ca-certificates
sudo update-ca-certificates
```

You can check that it has been added by running the following command. It should be the last entry in the list:

```bash
awk -v cmd='openssl x509 -noout -subject' '
    /BEGIN/{close(cmd)};{print | cmd}' < /etc/ssl/certs/ca-certificates.crt
```

## Configure the certificates and trust anchor as EAP credentials on the Raspberry PI

Edit the wpa_supplicant configuration. Edit out the cred configuration and update the network configuration:

```bash
cd /etc/wpa_supplicant
sudo nano wpa_supplicant.conf
```

Comment out the credential block and edit the network block:

```plaintext
# cred={
#        username=<username>
#        password=<password>
#}

network={
        ssid="<local ssid>"
        proto=RSN
        key_mgmt=WPA-EAP
        eap=TLS
        scan_ssid=1
        identity="myDevice"
        ca_cert="/etc/ssl/certs/ca.pem"
        client_cert="/etc/ssl/certs/client.pem"
        private_key="/etc/ssl/certs/client.key"
        private_key_passwd="whatever"
        eapol_flags=3
}
```

Fix a known problem with Raspberry PI with 4-way handshake ([issue link](https://forums.raspberrypi.com/viewtopic.php?t=253567)):

```bash
cd /etc/
sudo nano dhcpcd.conf
```

Add this line to the end of the file:

```plaintext
env wpa_supplicant_driver=wext
```

Now enable the wpa_supplicant via the CLI:

```bash
sudo wpa_cli
wpa_cli v2.8-devel
Copyright (c) 2004-2019, Jouni Malinen <j@w1.fi> and contributors

This software may be distributed under the terms of the BSD license.
See README for more details.
```

Re-initialize the WLAN interface:

```plaintext
> interface wlan0
connected to interface 'wlan0.'
> reconfigure
<OK>
<3>CTRL-EVENT-EAP-STARTED EAP authentication started
<3>CTRL-EVENT-EAP-STATUS status='started' parameter=''
<3>CTRL-EVENT-EAP-PROPOSED-METHOD vendor=0 method=13
<3>CTRL-E

VENT-EAP-STATUS status='accept proposed method' parameter='TLS'
<3>CTRL-EVENT-EAP-METHOD EAP vendor 0 method 13 (TLS) selected
<3>CTRL-EVENT-DISCONNECTED bssid=82:15:54:50:0f:1c reason=0
<3>CTRL-EVENT-SCAN-RESULTS
<3>WPS-AP-AVAILABLE-AUTH
<3>Trying to associate with 82:15:44:50:0f:1c (SSID='EAP-TLS Testing' freq=2412 MHz)
<3>Associated with 82:15:44:50:0f:1c
<3>CTRL-EVENT-EAP-STARTED EAP authentication started
<3>CTRL-EVENT-EAP-STATUS status='started' parameter=''
<3>CTRL-EVENT-EAP-PROPOSED-METHOD vendor=0 method=13
<3>CTRL-EVENT-EAP-STATUS status='accept proposed method' parameter='TLS'
<3>CTRL-EVENT-EAP-METHOD EAP vendor 0 method 13 (TLS) selected
<3>CTRL-EVENT-EAP-PEER-CERT depth=1 subject='/C=GB/ST=Berkshire/L=Maidenhead/O=OR4IoT Test CA/CN=OR4IoT Proof of Concept test CA' hash=e3687319866cd28fd7d208507ca59b69e009d121132d80cd1226f1ecb06f13f7
<3>CTRL-EVENT-EAP-PEER-CERT depth=1 subject='/C=GB/ST=Berkshire/L=Maidenhead/O=OR4IoT Test CA/CN=OR4IoT Proof of Concept test CA' cert=308204a73082038fa00302010202143a48cb9f16fe5aae1375adb82d1aa53234cb25d8300d06092a864886f70d01010b05003079310b30090603550406130247423112301006035504080c094265726b73686972653113301106035504070c0a4d616964656e6865616431173015060355040a0c0e4f5234496f5420546573742043413128302606035504030c1f4f5234496f542050726f6f66206f6620436f6e636570742074657374204341301e170d3234303330353132333632395a170d3234303530343132333632395a3079310b30090603550406130247423112301006035504080c094265726b73686972653113301106035504070c0a4d616964656e6865616431173015060355040a0c0e4f5234496f5420546573742043413128302606035504030c1f4f5234496f542050726f6f66206f6620436f6e63657074207465737420434130820122300d06092a864886f70d01010105000382010f003082010a0282010100c7c4b59b4933253f7510b4c7fb05d24aad0f0faebe2eb216f78634c5f30f0c9b5522490c4265f5439b06d5806fa4c7b981368139b1ce2f7919a122c8610531174a478adbd8c2ecad07e92c04a465476caba6533be5177e509b00c4c145652d8d175233ba525f0f57e2f3b49bb017ac141450fb552081db6273ee0ce41e398e84b3d55138709a988311bc7563e948517be2aeff8aa33130b217cdf334c7eac1fa40876694088c257ebc299d87bd05ba454bd83569e407f35b2175a0288de465b7e368ecc2d75178764193454a0b27492b5b77cc79b23fa32306bf17cdac03479737106401133c5ff17ded86e30cae9af8bee0d780b7918cd1ed47fe57aeba647f0203010001a382012530820121301d0603551d0e041604141af93de6b4b731e98a98820aeb807a679f52a2523081b60603551d230481ae3081ab80141af93de6b4b731e98a98820aeb807a679f52a252a17da47b3079310b30090603550406130247423112301006035504080c094265726b73686972653113301106035504070c0a4d616964656e6865616431173015060355040a0c0e4f5234496f5420546573742043413128302606035504030c1f4f5234496f542050726f6f66206f6620436f6e63657074207465737420434182143a48cb9f16fe5aae1375adb82d1aa53234cb25d8300f0603551d130101ff040530030101ff30360603551d1f042f302d302ba029a0278625687474703a2f2f7777772e6578616d706c652e636f6d2f6578616d706c655f63612e63726c300d06092a864886f70d01010b0500038201010082cbe5d98d23d06ce0ad58c6a5a7c53d19f29855ccacaee274775607d270d1f3825474eb350c96bfc6b7c5577e83754af530332fc4ff558fc5edc58576439e359d4d3067c299f4c34f1fb59b9e383da5db55595751fb9080b88e2e4ed05603bed34ca28b76eb9404f3e2839c687ca76bfaa8d8529364c5be3adbab0600b3d97f622e99901df9a725975959d33d274d62e3daa587767d701c2efede133459c9f6e52ee88ddbb10388cb159e2c5dc8793b581000ae715f816bb83d78a692401f6f9ef0a0223a59434e3548a2c0abc845b6e71d4c26ec7c7773bf7e7396af799216557f8d7f844f3004e795ae4f6d123afde2a4d17f531c59054fb9df89c9e25d7e
<3>CTRL-EVENT-EAP-PEER-CERT depth=0 subject='/C=GB/ST=Berkshire/O=OpenRoaming for IoT PoC/CN=Server certificate for OR4IoT PoC' hash=21dbc7b90aa4c07fe6634e07e5031c9cb801c63d6beac82d63eaa4684c779223
<3>CTRL-EVENT-EAP-PEER-CERT depth=0 subject='/C=GB/ST=Berkshire/O=OpenRoaming for IoT PoC/CN=Server certificate for OR4IoT PoC' cert=3082040e308202f6a003020102020103300d06092a864886f70d01010b05003079310b30090603550406130247423112301006035504080c094265726b73686972653113301106035504070c0a4d616964656e6865616431173015060355040a0c0e4f5234496f5420546573742043413128302606035504030c1f4f5234496f542050726f6f66206f6620436f6e636570742074657374204341301e170d3234303330353132333633305a170d3234303530343132333633305a306f310b30090603550406130247423112301006035504080c094265726b73686972653120301e060355040a0c174f70656e526f616d696e6720666f7220496f5420506f43312a302806035504030c2153657276657220636572746966696361746520666f72204f5234496f5420506f4330820122300d06092a864886f70d01010105000382010f003082010a02820101008d9c1a1d33c32c19ad038a41f0af4a1eaf18d1511846c15d70d57c1e5b443e80531d82

da7e0d8f2e375e0959a519d01af6ddaf2a2ea046519d68a4dc69dafe056fe81321e589b399c5afafe7fdc0809d726126cc1451014887c7392851b3412417390f92eb3805138896fb8c962a897a2838414d6b2423679d24bc13bc5cb546befba5f5f32e9b4828ecc50472f42fa059867189a6a69dbc3d3b83a32f3e97784df565627faf4683505af0b74753dff47033c8a7fbbe540dfc59bf1a69932a6d52a61dcb647f3aef1f3859d86d5339b831c4f898912c9f842ce2d81d87ef4c7371b09aecec66168e5859dc606d1e8ddfe674884fd36bd52b4e28eca731a891950203010001a381aa3081a730130603551d25040c300a06082b0601050507030130360603551d1f042f302d302ba029a0278625687474703a2f2f7777772e6578616d706c652e636f6d2f6578616d706c655f63612e63726c30180603551d200411300f300d060b2b0601040182be68010302301d0603551d0e041604149000567b788054a32278e25c7b2683df24c75531301f0603551d230418301680141af93de6b4b731e98a98820aeb807a679f52a252300d06092a864886f70d01010b050003820101009e72168abc7853cfd53b61729ee288bfdca837bde9c355fb6653419f5a974f336041d16615fdf86eb7ab66e305e500e99093b33c7841f9b10acb030a113e661b2d4c90f7ed24a78a3ea9ad2b14faaf6f64df0a048461ad4f4db830ef425db65b7ec8517b6672f84c8968e581b08ec74a395f9aadaab1b3bb16ea65b5a5a1970b24425c39cddc37764ff16c2dea61dfd86282e78ed6338504f54796439371024a2e6513759b3d719f73d47fb7f20e6468069b313106bedb06e1063023a8b53c7b9626494946010f6b687dd48fcb0d202e5f58bb67c8e4d728a6a3104c7bee689cc77c8ab275070f3bec81e7923dd29752399baa51e29ba9b41980b91759c69e77
<3>CTRL-EVENT-EAP-STATUS status='remote certificate verification' parameter='success'
<3>CTRL-EVENT-EAP-STATUS status='completion' parameter='success'
<3>CTRL-EVENT-EAP-SUCCESS EAP authentication completed successfully
<3>PMKSA-CACHE-ADDED 82:15:44:50:0f:1c 0
<3>WPA: Key negotiation completed with 82:15:44:50:0f:1c [PTK=CCMP GTK=CCMP]
<3>CTRL-EVENT-CONNECTED - Connection to 82:15:44:50:0f:1c completed [id=0 id_str=]
<3>CTRL-EVENT-SCAN-RESULTS
```

EAP-TLS is now configured correctly using wlan0.

<hr>

# Pulling it all together - switching from network block to credential block

Follow the instructions above to enable wpa_supplicant on wlan1. Now edit the credential block to use the EAP-TLS:

```bash
cd hostap/wpa_supplicant/
./wpa_cli -i wlan1 -p /var/run/wpa_supplicant1
```

And add the certificate credential:

```plaintext
> add_cred
0
<3>CRED-ADDED 0
> set_cred 0 realm "or4iot-test.org"
OK
<3>CRED-MODIFIED 0 realm
> set_cred 0 roaming_consortiums "5a03ba0000"
OK
<3>CRED-MODIFIED 0 roaming_consortiums
> set_cred 0 eap TLS
OK
<3>CRED-MODIFIED 0 eap
> set_cred 0 username "anonymous"
OK
<3>CRED-MODIFIED 0 username
> set_cred 0 ca_cert "/etc/ssl/certs/ca2.pem"
OK
<3>CRED-MODIFIED 0 ca_cert
> set_cred 0 client_cert "/etc/ssl/certs/client2.pem"
OK
<3>CRED-MODIFIED 0 client_cert
> set_cred 0 private_key "/etc/ssl/certs/client2.key"
OK
<3>CRED-MODIFIED 0 private_key
> set_cred 0 private_key_passwd "whatever"
OK
<3>CRED-MODIFIED 0 private_key_passwd
```

Start the Passpoint based automatic network selection and observe the EAP-TLS exchange:

```plaintext
> interworking_select auto
OK
<3>CTRL-EVENT-SCAN-STARTED
<3>Starting ANQP fetch for 82:15:54:50:0f:1c (HESSID 00:00:00:00:00:00)
<3>GAS-QUERY-START addr=82:15:54:50:0f:1c dialog_token=74 freq=5180
<3>GAS-QUERY-DONE addr=82:15:54:50:0f:1c dialog_token=74 freq=5180 status_code=0 result=SUCCESS
<3>RX-ANQP 82:15:54:50:0f:1c ANQP Capability list
<3>RX-HS20-ANQP 82:15:54:50:0f:1c HS Capability List
<3>ANQP-QUERY-DONE addr=82:15:54:50:0f:1c result=SUCCESS
<3>Starting ANQP fetch for 82:15:44:50:0f:1c (HESSID 00:00:00:00:00:00)
<3>GAS-QUERY-START addr=82:15:44:50:0f:1c dialog_token=127 freq=2412
<3>GAS-QUERY-DONE addr=82:15:44:50:0f:1c dialog_token=127 freq=2412 status_code=0 result=SUCCESS
<3>RX-ANQP 82:15:44:50:0f:1c ANQP Capability list
<3>RX-HS20-ANQP 82:15:44:50:0f:1c HS Capability List
<3>ANQP-QUERY-DONE addr=82:15:44:50:0f:1c result=SUCCESS
<3>ANQP fetch completed
<3>INTERWORKING-AP 82:15:54:50:0f:1c type=unknown id=0 priority=0 sp_priority=0
<3>INTERWORKING-AP 82:15:44:50:0f:1c type=unknown id=0 priority=0 sp_priority=0
<3>INTERWORKING-SELECTED 82:15:54:50:0f:1c
<3>CTRL-EVENT-NETWORK-ADDED 0
<3>Trying to associate with 82:15:54:50:0f:1c (SSID='EAP-TLS Testing' freq=5180 MHz)
<3>Associated with 82:15:54:50:0f:1c
<3>CTRL-EVENT-SUBNET-STATUS-UPDATE status=0
<3>CTRL-EVENT-EAP-STARTED EAP authentication started
<3>CTRL-EVENT-EAP-STATUS status='started' parameter=''
<3>CTRL-EVENT-EAP-PROPOSED-METHOD vendor=0 method=13
<3>CTRL-EVENT-EAP-STATUS status='accept proposed method' parameter='TLS'
<3>CTRL-EVENT-EAP-METHOD EAP vendor 0 method 13 (TLS) selected
<3>CTRL-EVENT-REGDOM-CHANGE init=COUNTRY_IE type=COUNTRY alpha2=GB
<3>CTRL-EVENT-EAP-PEER-CERT depth=1 subject='/C=GB/ST=Berkshire/L=Maidenhead/O=OR4IoT Test CA/CN=OR4IoT Proof of Concept test CA' hash=e3687319866cd28fd7d208507

ca59b69e009d121132d80cd1226f1ecb06f13f7
<3>CTRL-EVENT-EAP-PEER-CERT depth=1 subject='/C=GB/ST=Berkshire/L=Maidenhead/O=OR4IoT Test CA/CN=OR4IoT Proof of Concept test CA' cert=308204a73082038fa00302010202143a48cb9f16fe5aae1375adb82d1aa53234cb25d8300d06092a864886f70d01010b05003079310b30090603550406130247423112301006035504080c094265726b73686972653113301106035504070c0a4d616964656e6865616431173015060355040a0c0e4f5234496f5420546573742043413128302606035504030c1f4f5234496f542050726f6f66206f6620436f6e636570742074657374204341301e170d3234303330353132333633305a170d3234303530343132333633305a3079310b30090603550406130247423112301006035504080c094265726b73686972653113301106035504070c0a4d616964656e6865616431173015060355040a0c0e4f5234496f5420546573742043413128302606035504030c1f4f5234496f542050726f6f66206f6620436f6e63657074207465737420434130820122300d06092a864886f70d01010105000382010f003082010a0282010100c7c4b59b4933253f7510b4c7fb05d24aad0f0faebe2eb216f78634c5f30f0c9b5522490c4265f5439b06d5806fa4c7b981368139b1ce2f7919a122c8610531174a478adbd8c2ecad07e92c04a465476caba6533be5177e509b00c4c145652d8d175233ba525f0f57e2f3b49bb017ac141450fb552081db6273ee0ce41e398e84b3d55138709a988311bc7563e948517be2aeff8aa33130b217cdf334c7eac1fa40876694088c257ebc299d87bd05ba454bd83569e407f35b2175a0288de465b7e368ecc2d75178764193454a0b27492b5b77cc79b23fa32306bf17cdac03479737106401133c5ff17ded86e30cae9af8bee0d780b7918cd1ed47fe57aeba647f0203010001a382012530820121301d0603551d0e041604141af93de6b4b731e98a98820aeb807a679f52a2523081b60603551d230481ae3081ab80141af93de6b4b731e98a98820aeb807a679f52a252a17da47b3079310b30090603550406130247423112301006035504080c094265726b73686972653113301106035504070c0a4d616964656e6865616431173015060355040a0c0e4f5234496f5420546573742043413128302606035504030c1f4f5234496f542050726f6f66206f6620436f6e63657074207465737420434182143a48cb9f16fe5aae1375adb82d1aa53234cb25d8300f0603551d130101ff040530030101ff30360603551d1f042f302d302ba029a0278625687474703a2f2f7777772e6578616d706c652e636f6d2f6578616d706c655f63612e63726c300d06092a864886f70d01010b0500038201010082cbe5d98d23d06ce0ad58c6a5a7c53d19f29855ccacaee274775607d270d1f3825474eb350c96bfc6b7c5577e83754af530332fc4ff558fc5edc58576439e359d4d3067c299f4c34f1fb59b9e383da5db55595751fb9080b88e2e4ed05603bed34ca28b76eb9404f3e2839c687ca76bfaa8d8529364c5be3adbab0600b3d97f622e99901df9a725975959d33d274d62e3daa587767d701c2efede133459c9f6e52ee88ddbb10388cb159e2c5dc8793b581000ae715f816bb83d78a692401f6f9ef0a0223a59434e3548a2c0abc845b6e71d4c26ec7c7773bf7e7396af799216557f8d7f844f3004e795ae4f6d123afde2a4d17f531c59054fb9df89c9e25d7e
<3>CTRL-EVENT-EAP-PEER-CERT depth=0 subject='/C=GB/ST=Berkshire/O=OpenRoaming for IoT PoC/CN=Server certificate for OR4IoT PoC' hash=21dbc7b90aa4c07fe6634e07e5031c9cb801c63d6beac82d63eaa4684c779223 tod=2
<3>CTRL-EVENT-EAP-PEER-CERT depth=0 subject='/C=GB/ST=Berkshire/O=OpenRoaming for IoT PoC/CN=Server certificate for OR4IoT PoC' cert=3082040e308202f6a003020102020103300d06092a864886f70d01010b05003079310b30090603550406130247423112301006035504080c094265726b73686972653113301106035504070c0a4d616964656e6865616431173015060355040a0c0e4f5234496f5420546573742043413128302606035504030c1f4f5234496f542050726f6f66206f6620436f6e636570742074657374204341301e170d3234303330353132333633305a170d3234303530343132333633305a306f310b30090603550406130247423112301006035504080c094265726b73686972653120301e060355040a0c174f70656e526f616d696e6720666f7220496f5420506f43312a302806035504030c2153657276657220636572746966696361746520666f72204f5234496f5420506f4330820122300d06092a864886f70d01010105000382010f003082010a02820101008d9c1a1d33c32c19ad038a41f0af4a1eaf18d1511846c15d70d57c1e5b443e80531d82da7e0d8f2e375e0959a519d01af6ddaf2a2ea046519d68a4dc69dafe056fe81321e589b399c5afafe7fdc0809d726126cc1451014887c7392851b3412417390f92eb3805138896fb8c962a897a2838414d6b2423679d24bc13bc5cb546befba5f5f32e9b4828ecc50472f42fa059867189a6a69dbc3d3b83a32f3e97784df565627faf4683505af0b74753dff47033c8a7fbbe540dfc59bf1a69932a6d52a61dcb647f3aef1f3859d86d5339b831c4f898912c9f842ce2d81d87ef4c7371b09aecec66168e5859dc606d1e8ddfe674884fd36bd52b4e28eca731a891950203010001a381aa3081a730130603551d25040c300a06082b0601050507030130360603551d1f042f302d302ba029a0278625687474703a2f2f7777772e657861

6d706c652e636f6d2f6578616d706c655f63612e63726c30180603551d200411300f300d060b2b0601040182be68010302301d0603551d0e041604149000567b788054a32278e25c7b2683df24c75531301f0603551d230418301680141af93de6b4b731e98a98820aeb807a679f52a252300d06092a864886f70d01010b050003820101009e72168abc7853cfd53b61729ee288bfdca837bde9c355fb6653419f5a974f336041d16615fdf86eb7ab66e305e500e99093b33c7841f9b10acb030a113e661b2d4c90f7ed24a78a3ea9ad2b14faaf6f64df0a048461ad4f4db830ef425db65b7ec8517b6672f84c8968e581b08ec74a395f9aadaab1b3bb16ea65b5a5a1970b24425c39cddc37764ff16c2dea61dfd86282e78ed6338504f54796439371024a2e6513759b3d719f73d47fb7f20e6468069b313106bedb06e1063023a8b53c7b9626494946010f6b687dd48fcb0d202e5f58bb67c8e4d728a6a3104c7bee689cc77c8ab275070f3bec81e7923dd29752399baa51e29ba9b41980b91759c69e77
<3>CTRL-EVENT-EAP-STATUS status='remote certificate verification' parameter='success'
<3>CTRL-EVENT-EAP-STATUS status='completion' parameter='success'
<3>CTRL-EVENT-EAP-SUCCESS EAP authentication completed successfully
<3>PMKSA-CACHE-ADDED 82:15:54:50:0f:1c 0
<3>WPA: Key negotiation completed with 82:15:54:50:0f:1c [PTK=CCMP GTK=CCMP]
<3>CTRL-EVENT-CONNECTED - Connection to 82:15:54:50:0f:1c completed [id=0 id_str=]
```

## Check the FreeRADIUS logs

You see how the credential block is used to populate the RADIUS Access-Request from the RADIUS logs:

```plaintext
(0) Received Access-Request Id 36 from 192.168.128.2:48456 to 192.168.128.75:1812 length 441
(0)   User-Name = "anonymous@or4iot-test.org"
(0)   NAS-IP-Address = 192.168.128.2
(0)   NAS-Identifier = "COSTOMNASID"
(0)   NAS-Port-Type = Wireless-802.11
(0)   Service-Type = Framed-User
(0)   NAS-Port = 1
(0)   Calling-Station-Id = "3C-52-A1-A2-56-04"
(0)   Connect-Info = "CONNECT 54.00 Mbps / 802.11ac / RSSI: 64 / Channel: 36"
(0)   Acct-Session-Id = "47368CBFD154BAFD"
(0)   Acct-Multi-Session-Id = "D8A31083E7095EE2"
(0)   WLAN-Pairwise-Cipher = 1027076
(0)   WLAN-Group-Cipher = 1027076
(0)   WLAN-AKM-Suite = 1027073
(0)   Meraki-Network-Name = "Home Network - wireless"
(0)   Meraki-Ap-Name = "Ground Floor"
(0)   Meraki-Ap-Tags = " ground "
(0)   Called-Station-Id = "88-15-44-50-0F-1C:EAP-TLS Testing"
(0)   Operator-Name = "1VEVTVC1PUEVSQVRPUjE6R0I.wballiance.com"
(0)   Meraki-Device-Name = "Ground Floor"
(0)   Framed-MTU = 1400
(0)   EAP-Message = 0x02ba001e01616e6f6e796d6f7573406f7234696f742d746573742e6f7267
(0)   HS20-AP-Version = 1
(0)   Message-Authenticator = 0x75f7ee9a5daadd95357220dbd15d8c55
(0) # Executing section authorize from file /etc/freeradius/sites-enabled/default
(0)   authorize {
(0)     policy filter_username {
(0)       if (&User-Name) {
(0)       if (&User-Name)  -> TRUE
(0)       if (&User-Name)  {
<lines skipped>
(0) suffix: Checking for suffix after "@"
(0) suffix: Looking up realm "or4iot-test.org" for User-Name = "anonymous@or4iot-test.org"
(0) suffix: No such realm "or4iot-test.org"
(0)     [suffix] = noop
(0) eap: Peer sent EAP Response (code 2) ID 186 length 30
(0) eap: EAP-Identity reply, returning 'ok' so we can short-circuit the rest of authorize
(0)     [eap] = ok
(0)   } # authorize = ok
(0) Found Auth-Type = eap
(0) # Executing group from file /etc/freeradius/sites-enabled/default
(0)   authenticate {
(0) eap: Peer sent packet with method EAP Identity (1)
(0) eap: Calling submodule eap_tls to process data
(0) eap_tls: (TLS) Initiating new session
(0) eap_tls: (TLS) Setting verify mode to require certificate from client
(0) eap: Sending EAP Request (code 1) ID 187 length 6
(0) eap: EAP session adding &reply:State = 0x0e5fdaef0ee4d737
```
