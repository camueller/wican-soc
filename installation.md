# Installation
## Benötigte Bibliotheken
### mosquitto-clients
Für die Kommunikation mit dem WiCAN ODB2-Adapter wird der MQTT-Client "Mosquitto" verwendet. Das Paket `mosquitto-clients` läßt sich über den Paket-Manager installieren.

### jq
Der WiCAN ODB2-Adapter verpackt die CAN-Nachrichten für den Transport über MQTT in das JSON-Format. Zum Verarbeiten dieser Nachrichten wird das Programm `jq` benötigt, das sich über das gleichnamige Paket mittels Paket-Manager installieren lässt.

### bc
Die Berechnung des SoC aus den Inhalten der CAN-Nachrichten geht über die mathematischen Fähigkeiten der Bash-Shell hinaus. Deshalb wird das Programm `bc` benötigt, um komplexere Berechnungen durchführen zu können. Dieses lässt sich über das gleichnamige Paket mittels Paket-Manager installieren.

## Repository clonen
Zunächst muss das Repository in ein belilebiges Verzeichnis geclont werden:
```bash
git clone https://github.com/camueller/wican-soc.git
```
Das darin beim Clonen entstandene Verzeichnis `wican-soc` wird nachfolgend als WICAN_SOC_HOME bezeichnet.

## Konfiguration anpassen
Im Verzeichnis WICAN_SOC_HOME befindet sich die [config](https://github.com/camueller/wican-soc/blob/main/config)-Datei. Diese enhält die konfigurierbaren Parameter und deren Beschreibung. Die Werte der Parameter müssen entsprechend angepasst werden.

## Systemd
Zum Starten der beiden Scripts werden Systemd-Services verwendet. In deren Konfigurationsdateien müssen die Pfade zu den Shell-Scripts gesetzt werden:

In der Datei `WICAN_SOC_HOME/systemd/wican-status.service` muss die Zeile mit `ExecStart` angepasst werden, wobei der Pfad dem WICAN_SOC_HOME entsprechen muss.
```
ExecStart=/opt/sae/soc/wican-soc/wican-status.sh
```

Analog muss in der Datei `WICAN_SOC_HOME/systemd/wican-soc.service` die Zeile mit `ExecStart` angepasst werden, wobei der Pfad dem WICAN_SOC_HOME entsprechen muss.
```
ExecStart=/opt/sae/soc/wican-soc/wican-soc.sh
```

Aus dem systemd-Verzeichnis müssen diese Dateien verlinkt werden, wobei WICAN_SOC_HOME durch den tatsächlichen Pfad ersetzt werden muss:
```bash
$ cd /lib/systemd/system
$ sudo ln -s WICAN_SOC_HOME/systemd/wican-status.service
$ sudo ln -s WICAN_SOC_HOME/systemd/wican-soc.service
```

Jetzt muss der systemd dazu verlasst werden, die Konfiguration erneut zu lesen:
```bash
$ sudo systemctl daemon-reload
```

Die nachfolgende Befehle sind nur für `wican-status` beschrieben. Für `wican-soc` gelten sie analog.

Zum Start genügt:

```bash
$ sudo service wican-status start
```

Der Status inkl. verwendetem Profils und WiCAN-Geräte-ID lässt sich wie folgt anzeigen:

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

Zum Beenden genügt:

```bash
$ sudo service wican-status stop
```

Damit die Services auch nach einem Reboot gestartet werden, müssen sie entsprechend aktiviert werden:
```bash
$ sudo systemctl enable wican-soc
Created symlink /etc/systemd/system/multi-user.target.wants/wican-soc.service → /etc/systemd/system/wican-soc.service.
$ sudo systemctl enable wican-status
Created symlink /etc/systemd/system/multi-user.target.wants/wican-status.service → /etc/systemd/system/wican-status.service.
```

Die Konsole-Ausgaben der Scripts sind durch den Befehl `journalctl` verfügbar:
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
