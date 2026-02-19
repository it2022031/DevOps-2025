# DevOps-2025 — Runbook (Local & Online)

---

# Προαπαιτούμενα για Εκτέλεση

## Κοινά (Local & Online)

- **Ansible (core ≥ 2.13)** – για αυτοματοποιημένο provisioning και configuration.
- **SSH client (openssh-client)** – για σύνδεση στα VMs.
- **Python 3 στον host** – απαραίτητο για τη λειτουργία του Ansible.
- **Git** – για clone του repository.

---

## Επιπλέον για Local Εκτέλεση (Vagrant / VirtualBox)

- **VirtualBox 7.x** – provider για δημιουργία και εκτέλεση Virtual Machines.
- **Vagrant 2.4.x** – διαχείριση lifecycle VMs (create / up / halt / destroy).
- **Επαρκείς πόροι συστήματος (RAM/CPU)** – για ταυτόχρονη εκτέλεση πολλαπλών VMs.

---

# Περιπτώσεις Εκτέλεσης Ίδιου Script

Σε development περιβάλλον είναι πιθανό να απαιτηθεί δεύτερη ή τρίτη εκτέλεση του ίδιου script.

Πιθανοί λόγοι:

- Τα VMs καθυστερούν να ολοκληρώσουν πλήρως το boot.
- Υπηρεσίες (PostgreSQL, Nginx, MailHog κ.ά.) δεν είναι άμεσα διαθέσιμες.
- Αλλαγές configuration απαιτούν restart.
- Timing issues μεταξύ boot και provisioning.
- Προσωρινή αποτυχία service — σε επόμενη εκτέλεση το περιβάλλον έχει ήδη δημιουργηθεί και ολοκληρώνεται επιτυχώς.

---

# Περιβάλλοντα Εκτέλεσης

Το repository υποστηρίζει 2 περιβάλλοντα:

- **Local (Vagrant / VirtualBox)** – backend, db, front, dockerhost, k8shost, jenkins.
- **Online (Cloud VMs)** – μέσω inventories `infra/inventories/cloud_*.ini`.

Κατηγορίες εκτέλεσης:

- **DEPLOY** – εγκατάσταση / στήσιμο υπηρεσιών
- **SEED** – demo data (seed DB) + demo photos

---

# Σημαντική Σημείωση για Online Διευθύνσεις (Cloud)

Οι δημόσιες IP διευθύνσεις των Online VMs **δεν είναι στατικές**.

Κάθε φορά που οι Cloud VMs τερματίζονται και επανεκκινούνται (stop/start), είναι πιθανό να λαμβάνουν **νέα δημόσια IP**.

Για τον λόγο αυτό:

- Ενημερώνουμε κάθε φορά τα αντίστοιχα αρχεία `infra/inventories/cloud_*.ini`
- Τροποποιούμε τις IP διευθύνσεις στα inventories πριν από οποιοδήποτε deploy ή seed
- Οι θύρες (ports) παραμένουν ίδιες — αλλά η IP αλλάζει

---

# Online Ports (Cloud Environment)

## Online VMs

- **Backend VM**
  - MailHog: `:8025`

## Online Docker

- MailHog: `:8025`

## Online K8s

- MailHog (NodePort): `:30025`

## Online Jenkins

- Jenkins UI: `:8080`

---

# 1) LOCAL (Vagrant)

## 1.1 Ports

### A) backend / front

- **backend**
  - [http://127.0.0.1:8088](http://127.0.0.1:8088) (nginx)
  - [http://127.0.0.1:8025](http://127.0.0.1:8025) (MailHog UI)
- **front**
  - [http://127.0.0.1:8090](http://127.0.0.1:8090) (nginx)

### B) dockerhost

- [http://127.0.0.1:8081](http://127.0.0.1:8081) (frontend)
- [http://127.0.0.1:8080](http://127.0.0.1:8080) (backend)
- [http://127.0.0.1:8026](http://127.0.0.1:8026) (MailHog UI)
- [http://127.0.0.1:9002](http://127.0.0.1:9002) (MinIO console)

### C) k8shost

- [http://127.0.0.1:8082](http://127.0.0.1:8082) (ingress http)
- [https://127.0.0.1:8443](https://127.0.0.1:8443) (ingress https)
- 127.0.0.1:16443 (k8s api)
- [http://127.0.0.1:18025](http://127.0.0.1:18025) (MailHog UI μέσω port-forward)

### D) jenkins

- [http://127.0.0.1:8083](http://127.0.0.1:8083)

---

## 1.2 DEPLOY

### A) Deploy VMs (backend/db/front)

**Script:** `./scripts/deploy-vms.sh`\
**Playbook:** `ansible/vms/playbooks/site.yml`\
**Inventory:** `infra/inventories/vagrant_local.ini`

```bash
cd ~/Desktop/DevOps-2025
./scripts/deploy-vms.sh

cd ~/Desktop/DevOps-2025
export ANSIBLE_CONFIG=infra/ansible/ansible-local.cfg

ansible -i infra/inventories/vagrant_local.ini backend:db:front -m ping
ansible-playbook -i infra/inventories/vagrant_local.ini ansible/vms/playbooks/site.yml --limit backend:db:front
```

---

### B) Deploy Docker (dockerhost)

**Script:** `./scripts/deploy-docker.sh`\
**Playbook:** `ansible/docker/playbooks/docker_site.yml`\
**Inventory:** `infra/inventories/vagrant_local.ini`\
**Group:** `docker_nodes`

```bash
cd ~/Desktop/DevOps-2025
./scripts/deploy-docker.sh

cd ~/Desktop/DevOps-2025
export ANSIBLE_CONFIG=infra/ansible/ansible-local.cfg

ansible -i infra/inventories/vagrant_local.ini docker_nodes -m ping
ansible-playbook -i infra/inventories/vagrant_local.ini ansible/docker/playbooks/docker_site.yml --limit docker_nodes
```

---

### C) Deploy K8s (k8shost / microk8s)

**Script:** `./scripts/deploy-k8s.sh`

**Playbooks:**

- `ansible/k8s/playbooks/microk8s_install.yml`
- `ansible/k8s/playbooks/k8s_apply_core.yml`

**Inventory:** `infra/inventories/hosts.ini`\
**Group:** `k8s`

```bash
cd ~/Desktop/DevOps-2025
./scripts/deploy-k8s.sh

cd ~/Desktop/DevOps-2025
export ANSIBLE_CONFIG=infra/ansible/ansible-local.cfg

ansible -i infra/inventories/hosts.ini k8s -m ping
ansible-playbook -i infra/inventories/hosts.ini ansible/k8s/playbooks/microk8s_install.yml --limit k8s
ansible-playbook -i infra/inventories/hosts.ini ansible/k8s/playbooks/k8s_apply_core.yml --limit k8s
```

---

### D) Deploy Jenkins (jenkins VM)

**Script:** `./scripts/deploy-jenkins.sh`

**Playbooks:**

- `ansible/jenkins/playbooks/jenkins_install.yml`
- `ansible/jenkins/playbooks/jenkins_ssh_setup.yml`
- `ansible/jenkins/playbooks/add_jenkins_key.yml`

```bash
cd ~/Desktop/DevOps-2025
./scripts/deploy-jenkins.sh

cd ~/Desktop/DevOps-2025
export ANSIBLE_CONFIG=infra/ansible/ansible-local.cfg

ansible -i infra/inventories/vagrant_local.ini jenkins -m ping
ansible-playbook -i infra/inventories/vagrant_local.ini ansible/jenkins/playbooks/jenkins_install.yml --limit jenkins
ansible-playbook -i infra/inventories/vagrant_local.ini ansible/jenkins/playbooks/jenkins_ssh_setup.yml --limit jenkins
ansible-playbook -i infra/inventories/vagrant_local.ini ansible/jenkins/playbooks/add_jenkins_key.yml
```

---

## 1.3 LOCAL — SEED

### A) Seed VMs

**Script:** `./scripts/seed-vms.sh`

**Playbooks:**

- `ansible/vms/playbooks/vm_seed_like_k8s.yml`
- `ansible/vms/playbooks/vm_load_photos_like_k8s.yml`

```bash
cd ~/Desktop/DevOps-2025
./scripts/seed-vms.sh

cd ~/Desktop/DevOps-2025
export ANSIBLE_CONFIG=infra/ansible/ansible-local.cfg

ansible -i infra/inventories/vagrant_local.ini backend:db:front -m ping
ansible-playbook -i infra/inventories/vagrant_local.ini ansible/vms/playbooks/vm_seed_like_k8s.yml --limit backend:db
ansible-playbook -i infra/inventories/vagrant_local.ini ansible/vms/playbooks/vm_load_photos_like_k8s.yml --limit db
```

---

### B) Seed Docker

**Script:** `./scripts/seed-docker.sh`

**Playbooks:**

- `ansible/docker/playbooks/docker_seed_like_k8s.yml`
- `ansible/docker/playbooks/docker_load_photos_like_k8s.yml`

```bash
cd ~/Desktop/DevOps-2025
./scripts/seed-docker.sh

cd ~/Desktop/DevOps-2025
export ANSIBLE_CONFIG=infra/ansible/ansible-local.cfg

ansible -i infra/inventories/vagrant_local.ini docker_nodes -m ping || true
ansible -i infra/inventories/vagrant_local.ini docker -m ping || true

ansible-playbook -i infra/inventories/vagrant_local.ini ansible/docker/playbooks/docker_seed_like_k8s.yml --limit docker_nodes
ansible-playbook -i infra/inventories/vagrant_local.ini ansible/docker/playbooks/docker_load_photos_like_k8s.yml --limit docker_nodes
```

---

### C) Seed K8s

**Script:** `./scripts/seed-k8s.sh`

**Playbooks:**

- `ansible/k8s/playbooks/k8s_seed_db.yml`
- `ansible/k8s/playbooks/k8s_load_photos.yml`

```bash
cd ~/Desktop/DevOps-2025
./scripts/seed-k8s.sh

cd ~/Desktop/DevOps-2025
export ANSIBLE_CONFIG=infra/ansible/ansible-local.cfg

ansible -i infra/inventories/vagrant_local.ini k8s -m ping
ansible-playbook -i infra/inventories/vagrant_local.ini ansible/k8s/playbooks/k8s_seed_db.yml --limit k8s
ansible-playbook -i infra/inventories/vagrant_local.ini ansible/k8s/playbooks/k8s_load_photos.yml --limit k8s
```

---

### D) MailHog UI (K8s Port Forward)

**Script:** `./scripts/k8s-mailhog.sh`

```bash
cd ~/Desktop/DevOps-2025
./scripts/k8s-mailhog.sh
```

Open:

```
http://127.0.0.1:18025
```

---

# 2) ONLINE (Cloud)

## 2.1 ONLINE — DEPLOY

### A) Deploy Online VMs

```bash
cd ~/Desktop/DevOps-2025
./scripts/deploy-vms-online.sh
```

Inventory: `infra/inventories/cloud_vms.ini`\
Playbook: `ansible/online/vms/playbooks/site_vms_online_nginx.yml`

---

### B) Deploy Online Docker

```bash
cd ~/Desktop/DevOps-2025
./scripts/deploy-docker-online.sh
```

Inventory: `infra/inventories/cloud_docker.ini`\
Playbook: `ansible/online/docker/playbooks/site_docker_online_nginx.yml`\
Group: `docker_nodes`

---

### C) Deploy Online K8s

```bash
cd ~/Desktop/DevOps-2025
./scripts/deploy-k8s-online.sh
```

Inventory: `infra/inventories/cloud_k8s.ini`\
Playbook: `ansible/online/k8s/playbooks/site_k8s_online_nginx.yml`\
Group: `k8s_nodes`

---

## 2.2 ONLINE — SEED

### Seed Online VMs (Demo DB + Photos)

```bash
cd ~/Desktop/DevOps-2025
./scripts/seed-vms-online.sh
```

Inventory: `infra/inventories/cloud_vms.ini`

Playbooks:

- `ansible/online/vms/playbooks/online_seed_db.yml`
- `ansible/online/vms/playbooks/online_load_photos.yml`

---

#
