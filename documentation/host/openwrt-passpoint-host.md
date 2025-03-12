### How to Configure OpenRoaming on OpenWRT

Follow these steps to configure OpenRoaming on your OpenWRT device for seamless and secure Wi-Fi connections.

### Prerequisites

Before starting, ensure you have:
- An OpenWRT-compatible device with OpenRoaming-capable wireless interface.
- OpenWRT 21.02 or newer with `wpad` built with the `hs20` option.
- Full version of the `iw` package.
- 802.1x infrastructure (RADIUS/RADSECProxy server) details:
  - Server IP address
  - Port numbers
  - Shared secrets

### Steps to Configure OpenRoaming

1. **Check `wpad` for OpenRoaming Capability:**
   
   Run the following command to verify OpenRoaming support:

   ```bash
   strings /usr/sbin/wpad | grep hs20
   ```

   If nothing shows up, replace the default `wpad-basic` package with `wpad-openssl`:

   ```bash
   opkg update
   opkg remove wpad-basic
   opkg install wpad-openssl
   ```

2. **Install Required Packages:**

   Ensure you have the full version of the `iw` package:

   ```bash
   opkg install iw-full
   ```

3. **Configure Hostapd with UCI:**

   OpenWRT uses UCI (Unified Configuration Interface) to generate the `hostapd` configuration. Edit the wireless configuration file:

   ```bash
   nano /etc/config/wireless
   ```

   Add the following configuration for OpenRoaming:

   ```bash
   config wifi-iface 'radio1_openroaming5g'
       option acct_secret 'radsec'
       option acct_server 'xxx.xxx.xxx.xxx'
       option auth_secret 'radsec'
       option auth_server 'xxx.xxx.xxx.xxx'
       option device 'radio1'
       option encryption 'wpa3-mixed'
       option ifname 'wlan1-2'
       option hs20_operating_class '5173'
       option iw_venue_group '1'
       option iw_venue_type '7'
       option nasid 'OpenRoamingWRT'
       option network 'guest'
       option ssid 'OpenRoaming'
       option iw_ipaddr_type_availability '11'
       option iw_access_network_type '2'
       option iw_network_auth_type '00'
       option hs20_oper_friendly_name 'eng:OpenRoaming'
       list iw_venue_name 'eng:OpenRoaming'
       list iw_venue_url '1:https://openroaming.org'
       list operator_icon '64:64:eng:image/png:operator_icon:operator_icon.png'
       option country 'US'
       option proxy_arp '1'
       option ieee80211k '1'
       list iw_anqp_3gpp_cell_net '311,180'
       list iw_anqp_3gpp_cell_net '313,100'
       list iw_anqp_3gpp_cell_net '310,280'
       list iw_anqp_3gpp_cell_net '310,410'
       list iw_domain_name 'openroaming.org'
       list iw_roaming_consortium '5a03ba0000'
       list iw_roaming_consortium '004096'
       list iw_nai_realm '0,*.openroaming.org,13[5:6],21[2:4][5:7],23[5:1][5:2],50[5:1][5:2],18[5:1][5:2]'
       option anqp_domain_id '0'
       option bss_transition '1'
       option disable_dgaf '1'
       option disabled '0'
       option guest '1'
       option hotspot20 '1'
       option hs20 '1'
       option hs20_deauth_req_timeout '60'
       option internet '1'
       option isolate '1'
       option iw_asra '0'
       option iw_disable_dgaf '1'
       option iw_enabled '1'
       option iw_esr '0'
       option iw_internet '1'
       option iw_interworking '1'
       option iw_uesa '0'
       option mode 'ap'
       option request_cui '1'
       option wnm_sleep_mode_no_keys '1'
   ```

4. **Reload the Wireless Configuration:**

   Apply the new configuration:

   ```bash
   wifi
   ```

5. **Verify the Configuration:**

   Check if the interface is up and running:

   ```bash
   iwinfo
   ```

6. **Test the Connection:**

   Ensure your device connects automatically to the OpenRoaming network.

### OpenWRT Devices with Hotspot 2.0 and Passpoint 2.0 Support Tested

- [GL.iNet GL-MT6000 (Flint 2) WiFi 6 Router](https://amzn.to/3UnfDEw)
  - Be sure after running the config options above to run:

    ```bash
    opkg --force-overwrite install kmod-mt7921-common kmod-mt7921-firmware kmod-mt7921e kmod-mt7921s kmod-mt7921u kmod-mt76x2u kmod-mt76-connac kmod-mt76-core kmod-mt76-usb kmod-mt7615-common kmod-mt7615-firmware kmod-mt7615e kmod-mt76x2-common kmod-mt76x2u kmod-mt7915e kmod-mt7916-firmware kmod-mt7986-firmware
    ```

### Updating OpenWRT Packages for Hotspot 2.0 Support on OpenWRT

> **Note:** ***Perform this section while hardwired into the device via ethernet, it will temporarily disable WiFi.***

> **Note:** *These commands may uninstall other packages that have these as dependencies. If this happens, reinstall them after finishing this section.*

> **Note:** *These packages are touchy on their install order. If you get an error on your device, try uninstalling everything mentioned and installing the error package first. You can do this from the command line or the software page in the Luci admin page.*

Before configuring Hotspot 2.0 on OpenWRT, ensure that your system has the required packages installed. 

Use the following commands to install the necessary components:

```bash
opkg update && \
opkg --force-removal-of-dependent-packages remove iw gl-sdk4-repeater hostapd* wpad*  && \
opkg --force-overwrite --force-downgrade --force-removal-of-dependent-packages install wpad-openssl nano && \
opkg --force-overwrite --force-downgrade --force-removal-of-dependent-packages install iw-full hostapd-common && \
opkg --force-overwrite --force-removal-of-dependent-packages install kmod-mac80211 kmod-cfg80211
```

### Using USB External WiFi Cards on OpenWRT

#### External WiFi Adapters for HotSpot 2.0 Support on OpenWRT

We recommend these adapters for their overall OpenWRT compatibility and 802.11 AX support. Top down, best to worst in terms of OpenWRT compatibility.

{{< centerbutton href="https://amzn.to/3vYvHT4">}}Get Your ALFA AWUS036AXML Today!{{< /centerbutton >}}

- [ALFA AWUS036AXM WiFi 6E USB 3.0 USB Adapter, AXE3000 Tri-Band 6Ghz/5.8GHz/2.4GHz](https://amzn.to/3UrQVTG)
    - Has external and replaceable antennas and it supports either 2.4Ghz/5Ghz on WiFi 6. Once OpenWRT adds support, the device will also support the 6 GHz band in the future.
    - Requires OpenWRT Kernel Level 5.15/5.2 at least. Verify with `uname -r`.
    - Use the following command to install the appropriate drivers:

      ```bash
      opkg --force-overwrite install kmod-mt7921-common kmod-mt7921-firmware kmod-mt7921e kmod-mt7921s kmod-mt7921u kmod-mt76x2u kmod-mt76-connac kmod-mt76-core kmod-mt76-usb kmod-mt76x2-common kmod-mt76x2u
      ```

- [ALFA AWUS036AXML 802.11axe WiFi 6E USB 3.0 Adapter AXE3000, Tri-Band 6 GHz](https://amzn.to/3vYvHT4)
    - Has external and replaceable antennas and it has WiFi 7 and 6GHz support as soon as OpenWRT supports it.  Till then it is 2.4Ghz/5Ghz WiFi 6. 
    - Requires Kernel Level 6.6 at least. Ideally, 6.7. Verify with `uname -r`.
        - So far we can get it working on OpenWRT latest regardless of the documented kernel requirements, it will not work on unless if you can flash your device with OpenWRT 23.05.2 or newer. 
    - Use the following command to install the appropriate drivers:

      ```bash
      opkg --force-overwrite install kmod-mt76x2u kmod-mt76-connac kmod-mt76-core kmod-mt76-usb kmod-mt76x2-common kmod-mt76x2u kmod-mt7915e kmod-mt7916-firmware mt7981-wo-firmware
      ```

> The [AWUS036AXML](https://amzn.to/3vYvHT4) is definitely the best USB-based WiFi radio we could find. However, it lacks support on many devices. As of the moment of this article's writing, it is possible, but it'll be technically challenging for most. This is why we prefer to recommend the [AWUS036AXM](https://amzn.to/3UrQVTG) for most people.

> *For a list of other documented adapters that have support on Linux and OpenWRT See the [USB-WiFi Documentation Repo](https://github.com/morrownr/USB-WiFi/blob/main/home/USB_WiFi_Adapters_that_are_supported_with_Linux_in-kernel_drivers.md)*

#### Installing External USB WiFi Drivers on OpenWRT

```bash
# Add any more drivers you may need. 
# The most popular WiFi 5 and WiFi 6 adapters, including our recommended should be covered below.
# Command order and separation matters.
opkg --force-removal-of-dependent-packages remove kmod-mt7921-common kmod-mt7921-firmware kmod-mt7921e kmod-mt7921s kmod-mt7921u kmod-mt76x2u && \
opkg --force-overwrite install kmod-mt7921-common kmod-mt7921-firmware kmod-mt7921e kmod-mt7921s kmod-mt7921u kmod-mt76x2u kmod-ath10k-smallbuffers kmod-ath9k kmod-ath9k-common kmod-ath kmod-mac80211 kmod-cfg80211 && \
opkg --force-overwrite install kmod-thermal kmod-cfg80211 kmod-mac80211 kmod-mt76-connac kmod-mt76-core kmod-mt76-usb kmod-mt7615-common kmod-mt7615-firmware kmod-mt7615e kmod-mt76x0-common kmod-mt76x02-common kmod-mt76x02-usb kmod-mt76x0u kmod-mt76x2-common kmod-mt76x2u kmod-mt7915e kmod-mt7916-firmware
```

By following these steps, you can set up OpenRoaming on your OpenWRT device, providing seamless and secure Wi-Fi connectivity for your users. For more detailed instructions and advanced configurations, [read the full guide](https://simeononsecurity.com/guides/unlock-seamless-connectivity-hotspot-2.0-openwrt/).