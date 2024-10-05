# Neues Profil erstellen für einen Fahrzeughersteller oder ein Modell

Die Profile befinden sich im Verzeichnis `profile`. Für jedes Profil muss darin eine Datei mit dem Profilnamen und der Erweiterung `.sh` existieren.

Jedes Profil muss die folgenden Functions bereitstellen:

## `<profilname>_send_soc_request` (Beipiel: `nissan_send_soc_request`)
Diese Funktion muss die MQTT-Nachricht an den WiCAN senden, welche das Fahrzeug dazu veranlasst, eine Antwort mit dem SoC zu senden.

Die Funktion erhält einen fast fertig konfigurierten Aufruf von `mosquitto_pub` als `$1`. Lediglich der Parameter `-m <MQTT-Nachricht>` muss noch angefügt werden, wobei den Anführungszeichen innerhalb der JSON-Nachricht ein Backslash-Zeichen vorangestellt werden muss.

## `<profilname>_response_message_count` (Beipiel: `nissan_response_message_count`)
Diese Funktion muss lediglich die Anzahl der MQTT-Nachrichten zurückgeben, aus denen die Anwort des Fahrzeugs besteht. In den meisten Fällen ist das vermutlich 1. Diese Angabe ist erforderlich, damit der MQTT-Client auf die entsprechende Anzahl von MQTT-Nachrichten wartet, bevor deren Verarbeitung begonnnen wird.

## `<profilname>_parse_soc_response` (Beipiel: `nissan_parse_soc_response`)
Diese Funktion muss aus den MQTT-Nachricht(en) des Fahrzeugs den SoC ermitteln. Dazu erhält die Funktion Pfad und Namen der Datei, welche die MQTT-Nachricht(en) beinhaltet.

Für den Zugriff auf bestimmte Teile der Datei können die üblichen Unix-Tools (`grep`, `sed`, ...) verwendet werden. Weil die MQTT-Nachricht(en) im JSON-Format vorliegen ist jedoch innerhalb einer Zeile der JSON-Prozessor `jq` besser dazu geeignet.

Die Bytes der CAN-Nachricht befinden sich im `data`-Array des `frame`-Attributes. Die für die Berechnung des SoC notwendigen Bytes können mit `jq .frame[0].data[Byte-Index]` extrahiert werden, wobei `Byte-Index` die Werte 0 bis 7 haben kann. 

Zur Berechnung des SoC kann auch das Kommandozeilen-Rechner-Tool `bc` verwendet werden, falls die mathematischen Fähigkeiten der Bash-Shell nicht ausreichen. Siehe auch [bc command in Linux with examples](https://www.geeksforgeeks.org/bc-command-linux-examples/) und [bc - an arbitrary precision calculator language](https://www.gnu.org/software/bc/manual/html_mono/bc.html).