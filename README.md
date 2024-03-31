# Ansible Runner

Ansible Runner est un conteneur Docker qui permet d'exécuter des playbooks Ansible et des commandes sur des hôtes cibles de manière isolée et reproductible. Ce README fournit des instructions sur la façon d'utiliser ce conteneur Docker pour exécuter des playbooks Ansible et des commandes sur des hôtes cibles.

## Prérequis

- Docker doit être installé sur votre machine hôte.
- Les fichiers de configuration Ansible (playbooks, inventory, vars) et fichiers hosts.ini/hosts.yml doivent être disponibles localement sur votre système de fichiers. Ces fichiers doivent à mini être accessibles en lecture par l'utilisateur 2000
- La clée ssh privée et le fichier vault utilisé par ansible doivent être en permission 600 et propriétaire 2000:2000, ou subuid+2000 si votre daemon docker est paramétré pour utiliser un  user namespace remapping.

## Build local

git clone https://github.com/aymengazzah/ansible-runner.git
cd ansible-runner
docker build -t ansible-runner:1.0 .


## Utilisation

### Exécuter un playbook

Pour exécuter un playbook Ansible sur un hôte cible, utilisez la commande suivante :

```bash
docker run \
    -e ANSIBLE_USERNAME=ansible-username \
    -e ANSIBLE_HOST_KEY_CHECKING=False \
    -e ANSIBLE_INVENTORY_FILE=/ansible-project/inventory/hosts.ini \
    -e ANSIBLE_VAULT_PASSWORD_FILE=/ansible_vault.key \
    -e ANSIBLE_PRIV_KEY_FILE=/ansible_ssh.key \
    -v /chemin/vers/ansible_vault.key:/ansible_vault.key \
    -v /chemin/vers/ansible_ssh.key:/ansible_ssh.key \
    -v /chemin/vers/projet_ansible:/ansible-project \
    ansible-runner:1.0 \
    --playbook /ansible-project/playbooks/votre_playbook.yml \
    --target hostname_cible
```

Remplacez `/chemin/vers/` par le chemin absolu vers les fichiers `ansible_vault.key` et `ansible_ssh.key`. Remplacez également `votre_playbook.yml` par le nom de votre playbook Ansible et `hostname_cible` par l'adresse IP de l'hôte cible.

### Exécuter un playbook avec des variables supplémentaires

Pour exécuter un playbook Ansible avec des variables supplémentaires, utilisez la commande suivante :

```bash
docker run \
    -e ANSIBLE_USERNAME=ansible-username \
    -e ANSIBLE_HOST_KEY_CHECKING=False \
    -e ANSIBLE_INVENTORY_FILE=/ansible-project/inventory/hosts.ini \
    -e ANSIBLE_VAULT_PASSWORD_FILE=/ansible_vault.key \
    -e ANSIBLE_PRIV_KEY_FILE=/ansible_ssh.key \
    -v /chemin/vers/ansible_vault.key:/ansible_vault.key \
    -v /chemin/vers/ansible_ssh.key:/ansible_ssh.key \
    -v /chemin/vers/projet_ansible:/ansible-project \
    ansible-runner:1.0 \
    --playbook /ansible-project/playbooks/votre_playbook.yml \
    --target hostname_cible \
    --extra_var nom_variable_01=valeur_variable \
    --extra_var nom_variable_02=valeur_variable
```

Remplacez `nom_variable` par le nom de votre variable supplémentaire et `valeur_variable` par la valeur correspondante.

### Exécuter une commande

Pour exécuter une commande sur un hôte cible, utilisez la commande suivante :

```bash
docker run \
    -e ANSIBLE_USERNAME=ansible-username \
    -e ANSIBLE_HOST_KEY_CHECKING=False \
    -e ANSIBLE_INVENTORY_FILE=/ansible-project/inventory/hosts.ini \
    -e ANSIBLE_VAULT_PASSWORD_FILE=/ansible_vault.key \
    -e ANSIBLE_PRIV_KEY_FILE=/ansible_ssh.key \
    -v /chemin/vers/ansible_vault.key:/ansible_vault.key \
    -v /chemin/vers/ansible_ssh.key:/ansible_ssh.key \
    -v /chemin/vers/projet_ansible:/ansible-project \
    ansible-runner:1.0 \
    --command "votre_commande" \
    --target hostname_cible
```

Remplacez `votre_commande` par la commande que vous souhaitez exécuter sur l'hôte cible.

* Note: des commandes sont interdites par défaut dans le code du conteneur afin de réstrindre le pouvoir de ansible-runner. Elles sont définis par cette liste
```bash
dangerous_commands = ["rm", "sed", "dd", "mkfs", "wget", "curl", "apt", "yum", "dnf", "pip", "npm", "composer", "docker run", "docker stack rm", "docker service rm", "docker-compose", "kubectl", "helm", "rkt", "systemctl"]
```




### Entrer dans le conteneur

Pour entrer dans le conteneur Ansible Runner, utilisez la commande suivante :

```bash
docker run \
    -e ANSIBLE_USERNAME=ansible-username \
    -e ANSIBLE_HOST_KEY_CHECKING=False \
    -e ANSIBLE_INVENTORY_FILE=/ansible-project/inventory/hosts.ini \
    -e ANSIBLE_VAULT_PASSWORD_FILE=/ansible_vault.key \
    -e ANSIBLE_PRIV_KEY_FILE=/ansible_ssh.key \
    -v /chemin/vers/ansible_vault.key:/ansible_vault.key \
    -v /chemin/vers/ansible_ssh.key:/ansible_ssh.key \
    -v /chemin/vers/projet_ansible:/ansible-project \
    --entrypoint /bin/bash \
    -it ansible-runner:1.0
```

Cela vous permettra d'accéder à une invite de commande à l'intérieur du conteneur.

## Nettoyer les conteneurs

Pour supprimer les conteneurs qui ont démarré avec l'image ansible-runner, utilisez la commande suivante :

```bash
sudo docker ps -a --filter "ancestor=ansible-runner:1.0" -q | xargs -r sudo docker rm
```