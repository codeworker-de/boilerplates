# Ansible Template zum Installieren von Docker
In diesem Projekt befindet sich ein einfaches Template für die Installation von Docker mit Ansible innerhalb einer Debian/Ubuntu Distribution.

## Was ist Ansible?
In erster Linie ist Ansible ein commandline tool und gliedert sich zu den Infrastructure-as-Code (IaC) Tools und soll uns helfen, unsere Konfigurationen von Server Systemen zu automatisieren.  
Ansible gehört zu den sogenannten Konfigurationsmanagement Tools. Wir bilden mit YAML-Dateien den gewünschten Konfigurationszustand eines Server Systems ab.
Mit Ansible werden dann, die in den YAML-Dateien beschriebenen Zustände bzw. "Anweisungen", auf dem Zielsystem "ausgerollt".

## System requirements
Da Ansible keinen nativen Support für Windows besitzt, wird unter Windows ein aktiviertes "Subsystem for Linux", eine VM oder ein anderes Unixoides System benötigt.
Liegt so ein System vor, dann wird noch folgendes benötigt:

* [python](https://www.python.org/)
* [ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html)
* SSH-Zugang zu den Zielsystemen

---

## inventory.yml
In einem Inventory werden Gruppen und Hosts festgelegt. Hosts können mit ihrem FQDN oder einer IP-Adresse angegeben werden. Die festgelegten Gruppen werden in den jeweiligen "Playbooks" berücksichtigt. 
Im vorliegenden Inventory sind einpaar lokale System definiert. 
Diese sind dann natürlich an eure Gegebenheiten anzupassen.

## docker-playbook.yml
In den Playbooks befinden sich dann die "Anweisungen" die auf dem/den Zielsystem(en) durchgeführt werden sollen.
Was bedeutet, dass hier die Installation von Docker und dazu alle notwendigen Schritte abgebildet sind.

## Installation ausführen
Damit Ansible nun loslegen kann braucht ihr nur folgenden Befehl abzusetzen:

```bash
ansible-playbook -i inventory.yml -u USERNAME_AUF_ZIELSYSTEM docker-playbook.yml
```


