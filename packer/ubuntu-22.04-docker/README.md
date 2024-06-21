# Ubuntu Server Image (inkl. Docker) mit Packer

Dies ist ein Demo Projekt, in dem ein Ubuntu Server Image mit Packer erstellt werden kann.
Es dient zum Zweck des erlernens von Packer. Daher sind die in diesem enthaltenen Dateien ausschließlich für eigene Tests und zum erweitern seiner eigenen Kenntnisse gedacht.
Es soll als Leitfaden dienen und ist **NICHT** für einen produktiv Einsatz bestimmt!

## Was ist packer?
Packer ist in erster Linie ein commandline Tool aus dem Haus HashiCorp. HashiCorp ist ein Herstelle von weiteren bekannten Tools, wie etwa [Vagrant](https://www.vagrantup.com/) und [Terraform](https://www.terraform.io/). 
Mit Packer können für verschiedene Ziel-Plattformen Betriebssystem Images erzeugt werden.
Dazu sind nur einige wenige Konfigurationsdateien notwendig.
In diesem Repository befindet sich eine *.pkr.hcl-Datei, diese enthält die für Packer notwendigen Konfigurationen.

## Was ist Docker?
Docker ist ein Commandline-Tool zum Ausführen und Managen von Containern. Ein Container ermöglicht es Software quasi darin zu "verpacken" und diese dann innerhalb eines Containers auszuführen.
Werden die Container in einer Linux-Umgebung ausgeführt, dann spiegelt jeder laufende Container einen eigenen Prozess wider.
Container können nützlich sein, um eine gewisse Kapselung von einer Software und dem Betriebssystem zu erreichen. Dies fördert das "schnelle" Aktualisieren einer Software.

## Was ist Docker nicht?
Oftmals werden Container mit einer virtuellen Maschine gleich gestellt. Was jedoch falsch ist!
Da sich ein Container den Kernel mit dem darunter liegenden Betriebssystem teilt, muss somit ein Kernel bereitgestellt werden.
Diese sind *nicht* Teil eines Containers und müssen somit von einem Betriebssystem geliefert werden.

## System requirements
Um mit Packer und diesem Repo starten zu können, werden einige Tools benötigt:
* [Packer](https://www.packer.io/)
* [Vagrant](https://www.vagrantup.com/)
* [VirtualBox](https://www.virtualbox.org/)
* Access-Token zu deinem Proxmox Clusters

Mit diesem Setup seid ihr in der Lage ein Ubuntu Server Image mit Packer als Vagrant box für VirtualBox zu erzeugen.
Als weitere Möglichkeit könnt ihr auch ein Image bzw. ein Template für Proxmox erstellen. Dafür wird jedoch ein Proxmox-Cluster benötigt. Da die VM innerhalb des Proxmox-Clusters erstellt und die Konfigurationen dort durchgeführt werden. Am Ende wird dann ein Proxmox-Template erstellt von dem man dann Klone erzeugen kann.

---

## Erstellen des Images
Für die Erstellung haben wir nun mehrere Möglichkeiten. Entweder es soll das Image für **alle** oder nur für eine spezielle Zielplattform erstellt werden.
Egal für welche Variante man sich entscheidet, man muss die ```./credentials.pkr.hcl``` um die Informationen anpassen und diese beim  ```packer build``` mit angeben.

Bevor man einen ```packer build``` durchführt sollte man durch Packer einmal die Konfiguration validieren lassen. Dazu muss man ebenfalls die ```./credentials.pkr.hcl``` angeben.

```bash
packer validate -var-file="./credentials.pkr.hcl" ./ubuntu-22-04.pkr.hcl
```
### credentials.pkr.hcl
In dieser Datei werden die Zugangsdaten zum Proxmox-Cluster und die SSH Credentials für die jeweilig zu erzeugenden Images eingetragen.
Alternativ zu dieser Datei kann ebenfalls mit Umgebungsvariablen gearbeitet werden. Die Umgebungsvariablen müssen dann über den Präfix ```PKR_VAR_```verfügen.

### Alle Zielplattformen
Um das Image für alle zu erstellen ist der Command im Terminal bzw. der Commandline recht simpel:
```bash
packer build -var-file="./credentials.pkr.hcl" -force ./ubuntu-22-04.pkr.hcl
```

### VirtualBox und Vagrant
Für die Erstellung der Vagrant box mit dem VirtualBox Provider, kann folgender Command abgesetzt werden:
```bash
packer build -var-file="./credentials.pkr.hcl" -force -only=vagrant.virtualbox-iso.ubuntu-server ./ubuntu-22-04.pkr.hcl
```
### Proxmox
Die Erstellung des Proxmox Templates kann über folgenden Command durchgeführt werden:
```bash
packer build -var-file="./credentials.pkr.hcl" -force -only=proxmox.proxmox-iso.ubuntu-server ./ubuntu-22-04.pkr.hcl
```