# Fast flash tutorial for VCK190

> Updated on 04/16 2026, Kai Shi


## Notice

The BSP image of **2024.1** has been patched with the following tools:

- openssh
- scp
- dropbear
- pv
- GNU wget
- pv

And **boot from ramdisk** is enabled **as default**, which means the boot-bsp tcl **won't** boot the device from sdcard.


## Steps

- 1. Boot from ramdisk BSP

```bash
source /usr/xilinx/Vivado/2024.1/settings64.sh
xsdb /usr/xilinx/vck190/xilinx-vck190-2024.1/boot-bsp.txt
```

**Wait the board loading ramdisk bsp, after it boots, follow the next steps.**


- 2. Config Network (Not hardcoded to ramdisk yet, maybe someday...)

`10.161.90.190` is the IP address of VCK190, and `10.161.90.10` is the IP address of server.

```bash
ifconfig eth1 10.161.90.190 netmask 255.255.255.0 up
```

Then, exec `ifconfig eth1` to have a check.

**[Notice]**, the system boots from ramdisk will generate a random MAC address for eth. So, you need to manual clear the ARP cache of server every time you reboot VCK190, otherwise, the server will always fail to ping through the IP address of VCK190.

```bash
sudo arp -d 10.161.90.190
```


- 3. [Server-side] Launch HTTP server

**Switch to** your `sd_card.img` folder, e.g., `/home/shikai/vck190/sd_card.img`, then execute:

```bash
python -m http.server 10190
```

**[Notice]** DONT change the port `10190` for firewall rules (10190 has been enabled by me, this needs ADMIN authorization).

- 4.[VCK190] Download .img and FLASH it to sdcard

```bash
wget -O - "http://10.161.90.10:/sd_card.img" | pv | dd of=/dev/mmcblk0 bs=64M conv=fsync
```

- 5. reboot

```bash
reboot
```

