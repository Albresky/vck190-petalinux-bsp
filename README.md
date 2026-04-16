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

### 1. Boot from ramdisk BSP

```bash
source /usr/xilinx/Vivado/2024.1/settings64.sh
xsdb /usr/xilinx/vck190/xilinx-vck190-2024.1/boot-bsp.txt
```

**Wait the board loading ramdisk bsp, after it boots, follow the next steps.**


### 2. Config Network (Not hardcoded to ramdisk yet, maybe someday...)

`10.161.90.190` is the IP address of VCK190, and `10.161.90.10` is the IP address of server.

```bash
ifconfig eth1 10.161.90.190 netmask 255.255.255.0 up
```

Then, exec `ifconfig eth1` to have a check.

**[Notice]**, the system boots from ramdisk will generate a random MAC address for eth. So, you need to manual clear the ARP cache of server every time you reboot VCK190, otherwise, the server will always fail to ping through the IP address of VCK190.

```bash
sudo arp -d 10.161.90.190
```


### 3. [Server-side] Launch HTTP server

**Switch to** your `sd_card.img` folder, e.g., `/home/shikai/vck190/sd_card.img`, then execute:

```bash
python -m http.server 10190
```

**[Notice]** DONT change the port `10190` for firewall rules (10190 has been enabled by me, this needs ADMIN authorization).

### 4.[VCK190] Download .img and FLASH it to sdcard

```bash
wget -O - "http://10.161.90.10:/sd_card.img" | pv | dd of=/dev/mmcblk0 bs=64M conv=fsync
```

Expected output:

```bash
/ # wget -O - "http://10.161.90.10:10190/sd_card.img" | pv | dd of=/dev/mmcblk0                                        
bs=64M conv=fsync                                                                                                      
--2038-02-22 06:16:18--  http://10.161.90.10:10190/sd_card.img                                                         
Connecting to 10.161.90.10:10190... connected.                                                                         
HTTP request sent, awaiting response... 200 OK                                                                         
Length: 3171942400 (3.0G) [application/octet-stream]                                                                   
Saving to: 'STDOUT'                                                                                                    
                                                                                                                       
-                     0%[                    ]  11.31M  56.5MB/s               [  123.844360] random: crng init done   
-                     1%[                    ]  46.53M  58.1MB/s               59.3MiB 0:00:01 [59.3MiB/s] [<=>        
-                     3%[                    ] 114.71M  63.6MB/s                127MiB 0:00:02 [67.9MiB/s] [ <=>       
-                     6%[>                   ] 182.53M  65.1MB/s                195MiB 0:00:03 [67.9MiB/s] [  <=>      
-                     8%[>                   ] 249.78M  67.6MB/s    eta 43s     262MiB 0:00:04 [67.1MiB/s] [   <=>     
-                    10%[=>                  ] 317.53M  67.6MB/s    eta 42s     329MiB 0:00:05 [67.7MiB/s] [    <=>    
-                    11%[=>                  ] 336.65M  55.9MB/s    eta 41s     336MiB 0:00:08 [1.85MiB/s] [     <=>   
-                    11%[=>                  ] 336.71M  27.8MB/s    eta 69s     336MiB 0:00:11 [25.6KiB/s] [      <=>  
```

### 5. reboot the board

```bash
reboot
```

