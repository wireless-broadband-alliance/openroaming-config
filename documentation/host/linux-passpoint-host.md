### How to Use the Hotspot 2.0 Docker Container (HostAPD + DHCP Server)

This guide will walk you through the process of setting up and running the Hotspot 2.0 Docker container from the SimeonOnSecurity repository. This Docker container facilitates the deployment of a wireless access point (HostAP) and DHCP server, supporting Hotspot 2.0 on Linux systems.

#### **Requirements**
- Minimum Linux kernel for WiFi 6 device-based master (AP) and AP/VLAN modes: 5.19
  - Verify using `uname -r`
  - Ideally, you should get your Linux kernel to 6.1 or 6.6 if possible. Consult your OS maintainers.
  - See the [USB WiFi - Linux Kernel Support Matrix](https://github.com/morrownr/USB-WiFi/blob/main/home/USB_WiFi_Chipsets.md)
- Minimum of a WiFi 5/6 and AP Mode Capable WiFi Device
  - Drivers and Firmware for the device are installed and working on your Host OS.
- 1-2 Spare USB Ports
- 1-2 AP Compatible WiFi Adapters (1 for 2.4GHz and 1 for 5GHz)
- Administrative SSH Access to the Host Device

Ensure your system's Wi-Fi drivers are correctly installed and that your Wi-Fi adapter supports AP mode. Verify this with:

```shell
iw list
```

Look for "AP" under "Supported interface modes". Set your country's Wi-Fi regulations to comply with local laws. For example, for the US:

```shell
iw reg set US
```

#### **Recommended Hardware**

The Docker container includes defaults and assumptions for specific hardware adapters. Recommended adapters are:

- **[ALFA AWUS036AXM](https://amzn.to/3Texv3H)**: Supports 2.4GHz/5GHz on WiFi 6 and 6GHz in the future. Requires Linux Kernel Level 5.2 or above.
  - Use: `-e HT_CAPAB="[HT40+][LDPC][SHORT-GI-20][SHORT-GI-40][TX-STBC][RX-STBC1][MAX-AMSDU-7935]" -e VHT_CAPAB="[RXLDPC][SHORT-GI-80][TX-STBC-2BY1][SU-BEAMFORMEE][MU-BEAMFORMEE][RX-ANTENNA-PATTERN][TX-ANTENNA-PATTERN][RX-STBC-1][BF-ANTENNA-4][MAX-MPDU-11454][MAX-A-MPDU-LEN-EXP7]"`
- **[NETGEAR WiFi AC1200 (A6210)](https://amzn.to/3T5FdwX)**: Cheap and easy to install. Requires Linux Kernel Level 5.2 or above.
  - Use: `-e HT_CAPAB="[HT40+][LDPC][SHORT-GI-20][SHORT-GI-40][TX-STBC][RX-STBC1]" -e VHT_CAPAB="[RXLDPC][SHORT-GI-80][TX-STBC-2BY1][RX-ANTENNA-PATTERN][TX-ANTENNA-PATTERN][RX-STBC-1][MAX-A-MPDU-LEN-EXP3]"`
- **[ALFA AWUS036AXML](https://amzn.to/3vYvHT4)**: Supports WiFi 7 and 6GHz. Requires Kernel Level 6.6 or above.
  - Use: `-e HT_CAPAB="[HT40+][LDPC][SHORT-GI-20][SHORT-GI-40][TX-STBC][RX-STBC1][MAX-AMSDU-7935]" -e VHT_CAPAB="[RXLDPC][SHORT-GI-80][TX-STBC-2BY1][SU-BEAMFORMEE][MU-BEAMFORMEE][RX-ANTENNA-PATTERN][TX-ANTENNA-PATTERN][RX-STBC-1][BF-ANTENNA-4][MAX-MPDU-11454][MAX-A-MPDU-LEN-EXP7]"`

For other adapters, refer to the [USB-WiFi Documentation Repo](https://github.com/morrownr/USB-WiFi/blob/main/home/USB_WiFi_Adapters_that_are_supported_with_Linux_in-kernel_drivers.md).

#### **Updating the Linux Kernel**

Updating the Linux kernel is an involved process and varies by system. For Ubuntu on non-ARM devices, refer to:
- [PhoenixNAP Guide](https://phoenixnap.com/kb/how-to-update-kernel-ubuntu)
- [It's FOSS Guide](https://itsfoss.com/upgrade-linux-kernel-ubuntu/)

#### **Build the Container**

If you need to build the Docker container image manually from the source code available in the repository, follow these steps:

1. **Clone the Repository:**
   First, clone the repository to your local machine using Git:

   ```bash
   git clone https://github.com/simeononsecurity/linux-hostapd-hs20-dhcpd.git
   cd linux-hostapd-hs20-dhcpd
   ```

2. **Build the Docker Image:**
   Navigate to the directory where the `Dockerfile` is located and build the Docker image using the `docker build` command:

   ```bash
   sudo docker build -t simeononsecurity/linux-hostapd-hs20-dhcpd .
   ```

3. **Verify the Image:**
   After the build process completes, verify that the Docker image has been created successfully by listing your Docker images:

   ```bash
   sudo docker images
   ```

   You should see an entry for `simeononsecurity/linux-hostapd-hs20-dhcpd` in the list.

4. **Run the Container:**
   Once the image is built, you can run the container using the instructions provided in the earlier sections for either host networking or network interface reattaching.

By following these steps, you will have manually built the Docker container image from the repository. This approach can be useful if you want to customize the Dockerfile or include additional configurations before building the image.

#### **Running the Container**

**Using Host Networking:**

```shell
sudo docker run -i -t -e INTERFACE=wlan1 -e OUTGOINGS=eth0 --net host --privileged simeononsecurity/linux-hostapd-hs20-dhcpd
```

**Using Network Interface Reattaching:**

```shell
sudo docker run -d -t -e INTERFACE=wlan0 -v /var/run/docker.sock:/var/run/docker.sock --privileged simeononsecurity/linux-hostapd-hs20-dhcpd
```

This method requires access to the Docker socket to manage network interfaces dynamically.

#### **Environment Variables**

Customize the container with environment variables:

- **INTERFACE**: Wi-Fi interface for the access point.
- **OUTGOINGS**: Outgoing network interface for internet access.
- **CHANNEL**: Wi-Fi channel (e.g., 6).
- **SUBNET**: Network subnet (e.g., 192.168.200.0).
- **AP_ADDR**: Access point's IP address (e.g., 192.168.200.1).
- **SSID**: SSID of the Wi-Fi network.
- **HW_MODE**: Wi-Fi hardware mode (e.g., `g` for 2.4 GHz).
- **DRIVER**: Wi-Fi driver, defaulting to `nl80211`.
- **HT_CAPAB**: Defines 802.11n HT capabilities.

For the complete list, refer to [CONFIG.MD](CONFIG.MD).

#### **Suggested Configurations for Recommended Hardware**

**[ALFA AWUS036AXM](https://amzn.to/3Texv3H)**

```bash
sudo docker pull simeononsecurity/linux-hostapd-hs20-dhcpd
sudo docker run -td  \
-e INTERFACE=wlx13370420xx0x \
-e AP_ADDR=192.168.200.1 \
-e SUBNET=192.168.200.0 \
-e OUTGOINGS=eno1 \
-e ACCT_SERVER_ADDR="XXX.XXX.XXX.XXX" \
-e AUTH_SERVER_ADDR="XXX.XXX.XXX.XXX" \
-e VHT_ENABLED=1 \
-e CHANNEL=161 \
-e SSID="OpenRoaming" \
-e HT_CAPAB="[HT40+][LDPC][SHORT-GI-20][SHORT-GI-40][TX-STBC][RX-STBC1][MAX-AMSDU-7935]" \
-e VHT_CAPAB="[RXLDPC][SHORT-GI-80][TX-STBC-2BY1][SU-BEAMFORMEE][MU-BEAMFORMEE][RX-ANTENNA-PATTERN][TX-ANTENNA-PATTERN][RX-STBC-1][BF-ANTENNA-4][MAX-MPDU-11454][MAX-A-MPDU-LEN-EXP7]" \
--privileged  \
--net host \
--name wifiap \
--restart unless-stopped \
-v /var/run/docker.sock:/var/run/docker.sock \
simeononsecurity/linux-hostapd-hs20-dhcpd
```

**[NETGEAR WiFi AC1200 (A6210)](https://amzn.to/3T5FdwX)**

```bash
sudo docker pull simeononsecurity/linux-hostapd-hs20-dhcpd
sudo docker run -td  \
-e INTERFACE=wlx13370420xx0x \
-e AP_ADDR=192.168.200.1 \
-e SUBNET=192.168.200.0 \
-e OUTGOINGS=eno1 \
-e ACCT_SERVER_ADDR="XXX.XXX.XXX.XXX" \
-e AUTH_SERVER_ADDR="XXX.XXX.XXX.XXX" \
-e VHT_ENABLED=1 \
-e CHANNEL=161 \
-e SSID="OpenRoaming" \
-e HT_CAPAB="[HT40+][LDPC][SHORT-GI-20][SHORT-GI-40][TX-STBC][RX-STBC1]" \
-e VHT_CAPAB="[RXLDPC][SHORT-GI-80][TX-STBC-2BY1][RX-ANTENNA-PATTERN][TX-ANTENNA-PATTERN][RX-STBC-1][MAX-A-MPDU-LEN-EXP3]" \
--privileged  \
--net host \
--name wifiap \
--restart unless-stopped \
-v /var/run/docker.sock:/var/run/docker.sock \
simeononsecurity/linux-hostapd-hs20-dhcpd
```

**[ALFA AWUS036AXML](https://amzn.to/3vYvHT4)**

```bash
sudo docker pull simeononsecurity/linux-hostapd-hs20-dhcpd
sudo docker run -td  \
-e INTERFACE=wlx13370420xx0x \
-e AP_ADDR=192.168.

200.1 \
-e SUBNET=192.168.200.0 \
-e OUTGOINGS=eno1 \
-e ACCT_SERVER_ADDR="XXX.XXX.XXX.XXX" \
-e AUTH_SERVER_ADDR="XXX.XXX.XXX.XXX" \
-e VHT_ENABLED=1 \
-e CHANNEL=161 \
-e SSID="OpenRoaming" \
-e HT_CAPAB="[HT40+][LDPC][SHORT-GI-20][SHORT-GI-40][TX-STBC][RX-STBC1][MAX-AMSDU-7935]" \
-e VHT_CAPAB="[RXLDPC][SHORT-GI-80][TX-STBC-2BY1][SU-BEAMFORMEE][MU-BEAMFORMEE][RX-ANTENNA-PATTERN][TX-ANTENNA-PATTERN][RX-STBC-1][BF-ANTENNA-4][MAX-MPDU-11454][MAX-A-MPDU-LEN-EXP7]" \
--privileged  \
--net host \
--name wifiap \
--restart unless-stopped \
-v /var/run/docker.sock:/var/run/docker.sock \
simeononsecurity/linux-hostapd-hs20-dhcpd
```

#### **Health Checks**

The container includes health checks to ensure [`hostapd`](https://w1.fi/hostapd/) and [`dhcpd`](https://en.wikipedia.org/wiki/DHCPD) are running correctly and that the specified network interface is operational.

#### **Docker Host OS WiFi Driver Script**

The script [`wifi-firmware.sh`](https://raw.githubusercontent.com/simeononsecurity/linux-hostapd-hs20-dhcpd/main/wifi-firmware.sh) is a Bash utility designed for downloading and installing firmware files for various WiFi chipsets from MediaTek (such as mt7925, mt7922, mt7961, mt7662, mt7610) and Realtek (rtw88 series).

The script automates the process of creating the necessary directories (if they do not already exist), downloading firmware files from the specified URLs using `wget`, and copying them to the appropriate locations in `/lib/firmware`. This setup is crucial for ensuring that the Linux system recognizes and correctly operates the WiFi hardware.

To use the script, simply execute it with Bash in a Linux environment that has internet access. It requires `sudo` privileges to create directories and copy files into the system's firmware directory. This script streamlines the firmware installation process for supported WiFi devices, making it an essential tool for system administrators and users looking to manually update or install WiFi drivers on their Linux systems.

#### **License**

No license is given at this time until we decide what needs to happen. All rights reserved.

#### **Acknowledgments**

- Original inspiration from [sdelrio's RPi-hostap](https://github.com/sdelrio/rpi-hostap) implementation.
- Docker container and health check enhancements by [SimeonOnSecurity](https://simeononsecurity.com).

For additional details and configurations, refer to the Dockerfile and the accompanying [`docker-init.sh`](docker-init.sh) and [`healthcheck.sh`](healthcheck.sh) scripts provided with [the container](https://github.com/simeononsecurity/linux-hostapd-hs20-dhcpd).