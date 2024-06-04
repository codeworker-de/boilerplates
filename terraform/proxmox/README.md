# Terraform Template für VMs in Proxmox
In diesem Projekt werden per Terraform neue VMs (full clones, **keine** linked clones) in einem Proxmox Cluster gemanaged. 

## Was ist Terraform?
Terraform soll uns helfen unsere Infrastruktur (bspw. VMs) automatisiert managen zu können. Ohne das wir noch manuelle Konfigurationsschritte durchführen müssen. Dazu 
beschreiben wir mit YAML-Dateien, wie zum Beispiel eine VM aussehen soll. Also, bspw. über wie viele CPUs & RAM sie verfügen soll. An welche Netzwerkkarte sie angebunden ist usw. Ebenfalls steuern wir, wie viele VMs es geben soll, von welchem "Template" sie abgeleitet ist etc.
Das bedeutet, dass Terraform mit zu den Tools gehört, mit denen wir unsere Infrastruktur-als-Code (Infrstructure-as-Code; IaC) beschreiben und in eine Versionskontrolle wie git einchecken.

---

## System requirements
Folgende Dinge brauchst du, damit es funktioniert:

* [Terraform](https://www.terraform.io/)
* Access-Token zu deinem Proxmox Cluster
* Ein "Template" im Proxmox Cluster 

### Proxmox Template
Es wird ein Template in deinem Proxmox Cluster benötigt. Wenn du noch keins hast, dann kannst du dir eines, mit Hilfe des unter [../../packer/ubuntu-22.04/](../../packer/ubuntu-22.04/) liegendes Template,
erstellen. Schau dazu einfach mal in die [README](../../packer/ubuntu-22.04/README.md).
Danach kannst du dann hier weiter machen 😊

---

## Dateien

### provider.tf
In dieser Datei sind allgemeine Daten festgelegt. Sprich, mit welchem Provider(n) wir arbeiten möchten, welche Variablen vorhanden sind und die Verbindungskonfiguration zu Proxmox.

### credentials.auto.tfvars
Diese Datei dient nur zur Veranschaulichung und sollte **nicht** Bestandteil von eurem Repo sein. Für Tests könnt ihr zwar dort eure Zugangsdaten zum Proxmox Cluster eintragen, solltet sie aber dann auch umbenennen.
Jede Datei mit der Dateiendung `.auto.tfvars` wird von Terraform automatisch einbezogen und dessen Inhalt dann in die passenden Variablen gesetzt. Sofern sie sich im selben Verzeichnis befindet, von dem aus ihr den `terraform` Befehl absetzt.
Es ist somit keine weitere Option beim `terraform` Befehl notwendig.

### srv-demo1.tf 
Das ist nun die eigentliche Ressource, die gemanaged werden soll. Darin befindet sich dann die Konfiguration der einzelnen VM. Mit den Angaben zu CPU, RAM, HDD usw.
Man kann diese Datei für weitere VMs duplizieren und anpassen oder auch weitere VMs in diese Datei direkt aufnehmen. Das bleibt euch natürlich freigestellt.


## Provider installieren
Damit Terraform auch die Verbindung zu eurem Zielsystem (hier Proxmox) herstellen kann, müsst ihr ersteinmal den Provider herunterladen. Dieser ist in der [provider.tf](./provider.tf) definiert.

Dazu einfach folgenden Befehl absetzen:
```bash
terraform init
```

## Deployment von einer VM
Nach dem der Provider installiert ist und ihr eure Konfigurationen in den passenden Dateien durchgeführt habt, ist es nun an der Zeit die VM(s) zu deployen.

Dazu folgenden Befehl absetzen:

```bash
terraform apply -auto-approve
```
Die Option `-auto-approve` dient dazu, dass wir die Änderungen nicht noch einmal extra bestätigen müssen.

## VM löschen
Werden die VMs bzw. wird die VM nicht mehr benötigt, dann können wir diese auch per Terraform löschen lassen.

Dazu folgenden Befehl absetzen:

```bash
terraform destroy
```