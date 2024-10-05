# Installation
## Required libraries
### mosquitto clients
The MQTT client “Mosquitto” is used to communicate with the WiCAN ODB2 adapter. The package `mosquitto-clients` can be installed via the package manager.

### jq
The WiCAN ODB2 adapter packages the CAN messages into JSON format for transport over MQTT. To process these messages, the program `jq` is required, which can be installed using the package of the same name using the package manager.

### bc
Calculating the SoC from the contents of the CAN messages goes beyond the mathematical capabilities of the Bash shell. Therefore the program `bc` is needed to carry out more complex calculations. This can be installed using the package of the same name using the package manager.

## Clone repository
First, the repository must be cloned into any directory:
```bash
git clone https://github.com/camueller/wican-soc.git
```
The `wican-soc` directory created herin during cloning is referred to as WICAN_SOC_HOME.

## Adjust configuration
The WICAN_SOC_HOME directory contains the [config](https://github.com/camueller/wican-soc/blob/main/config) file. This contains the configurable parameters and their description. The values of the parameters must be adjusted accordingly.

## Systemd
Systemd services are used to start the two scripts. The paths to the shell scripts must be set in their configuration files:

In the file `WICAN_SOC_HOME/systemd/wican-status.service` the line with `ExecStart` must be adjusted, whereby the path must correspond to the WICAN_SOC_HOME.
```
ExecStart=/opt/sae/soc/wican-soc/wican-status.sh
```

Similarly, in the file `WICAN_SOC_HOME/systemd/wican-soc.service` the line with `ExecStart` must be adjusted, whereby the path must correspond to WICAN_SOC_HOME.
```
ExecStart=/opt/sae/soc/wican-soc/wican-soc.sh
```

From the systemd directory, these files must be linked, replacing WICAN_SOC_HOME with the actual path:
```bash
$ cd /lib/systemd/system
$ sudo ln -s WICAN_SOC_HOME/systemd/wican-status.service
$ sudo ln -s WICAN_SOC_HOME/systemd/wican-soc.service
```

Now the systemd must be left to read the configuration again:
```bash
$ sudo systemctl daemon reload
```

The following commands are only described for `wican-status`. They apply analogously to `wican-soc`.

To start, all you need is:
```bash
$ sudo service wican status start
```

The status including the profile used and WiCAN device ID can be displayed as follows:
```bash
$ sudo service wican-status status
● wican-status.service - WiCan status monitor
     Loaded: loaded (/opt/sae/soc/wican-soc/systemd/wican-status.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2024-10-04 16:32:28 CEST; 7s ago
   Main PID: 9564 (wican-status.sh)
      Tasks: 2 (limit: 3933)
        CPU: 39ms
     CGroup: /system.slice/wican-status.service
             ├─9564 /bin/bash /opt/sae/soc/wican-soc/wican-status.sh
             └─9574 mosquitto_sub -h localhost -t wican/12345678901d/status -C 1

Oct 04 16:32:28 raspi2 systemd[1]: Started WiCan status monitor.
Oct 04 16:32:28 raspi2 wican-status.sh[9564]: Using profile nissan for WiCAN device 12345678901d
Oct 04 16:32:28 raspi2 wican-status.sh[9564]: Waiting for message ...
```

To stop, just type:
```bash
$ sudo service wican-status stop
```

In order for the services to be started even after a reboot, they must be activated accordingly:
```bash
$ sudo systemctl enable wican-soc
Created symlink /etc/systemd/system/multi-user.target.wants/wican-soc.service → /etc/systemd/system/wican-soc.service.
$ sudo systemctl enable wican-status
Created symlink /etc/systemd/system/multi-user.target.wants/wican-status.service → /etc/systemd/system/wican-status.service.
```

The console output of the scripts is available through the `journalctl` command:
```bash
sudo journalctl _SYSTEMD_UNIT=wican-soc.service
Oct 04 12:55:28 raspi2 wican-soc.sh[8429]: Using profile nissan for WiCAN device 12345678901d
Oct 04 12:55:28 raspi2 wican-soc.sh[8429]: Expecting response to consist of 8 CAN message(s)
Oct 04 12:55:28 raspi2 wican-soc.sh[8429]: Waiting for messages ...
Oct 04 12:58:58 raspi2 wican-soc.sh[8429]: Message received:
Oct 04 12:58:58 raspi2 wican-soc.sh[8485]: {"bus":"0","type":"rx","ts":6724,"frame":[{"id":1979,"dlc":8,"rtr":false,"extd":false,"data":[16,53,97,1,255,255,252,24]}]}
Oct 04 12:58:58 raspi2 wican-soc.sh[8485]: {"bus":"0","type":"rx","ts":6836,"frame":[{"id":1979,"dlc":8,"rtr":false,"extd":false,"data":[33,2,175,255,255,251,213,255]}]}
Oct 04 12:58:58 raspi2 wican-soc.sh[8485]: {"bus":"0","type":"rx","ts":6844,"frame":[{"id":1979,"dlc":8,"rtr":false,"extd":false,"data":[34,255,240,96,6,208,48,212]}]}
Oct 04 12:58:58 raspi2 wican-soc.sh[8485]: {"bus":"0","type":"rx","ts":6856,"frame":[{"id":1979,"dlc":8,"rtr":false,"extd":false,"data":[35,150,136,56,189,3,143,0]}]}
Oct 04 12:58:58 raspi2 wican-soc.sh[8485]: {"bus":"0","type":"rx","ts":6869,"frame":[{"id":1979,"dlc":8,"rtr":false,"extd":false,"data":[36,1,112,0,34,66,0,12]}]}
Oct 04 12:58:58 raspi2 wican-soc.sh[8485]: {"bus":"0","type":"rx","ts":6876,"frame":[{"id":1979,"dlc":8,"rtr":false,"extd":false,"data":[37,135,10,0,15,240,136,128]}]}
Oct 04 12:58:58 raspi2 wican-soc.sh[8485]: {"bus":"0","type":"rx","ts":6884,"frame":[{"id":1979,"dlc":8,"rtr":false,"extd":false,"data":[38,0,5,255,255,251,213,255]}]}
Oct 04 12:58:58 raspi2 wican-soc.sh[8485]: {"bus":"0","type":"rx","ts":6896,"frame":[{"id":1979,"dlc":8,"rtr":false,"extd":false,"data":[39,255,252,85,1,174,255,255]}]}
Oct 04 12:58:58 raspi2 wican-soc.sh[8429]: Parsing SOC response ...
Oct 04 12:58:59 raspi2 wican-soc.sh[8429]: SOC=84
Oct 04 12:58:59 raspi2 wican-soc.sh[8429]: Publishing SOC MQTT message ...
Oct 04 12:58:59 raspi2 wican-soc.sh[8429]: Sleeping ...
Oct 04 12:59:09 raspi2 wican-soc.sh[8429]: Waiting for messages ...
```
