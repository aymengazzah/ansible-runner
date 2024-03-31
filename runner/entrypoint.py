import argparse
import subprocess
import os
from pathlib import Path

# Fonction pour exécuter le script regex_vars.sh s'il existe
def run_regex_vars():
    """
    Run the regex_vars.sh script
    """
    regex_vars_script = Path("/runner/regex_vars.sh")
    if regex_vars_script.exists():
        try:
            subprocess.run([str(regex_vars_script)], check=True)
        except subprocess.CalledProcessError as e:
            print(f"Error running regex_vars.sh: {e}")
            raise

# Fonction pour exécuter un playbook Ansible
def run_playbook(playbook_path, target=None, extra_vars=None):
    """
    Run the playbook specified by playbook_path
    """
    command = ["ansible-playbook", playbook_path]
    if target:
        command.extend(["-e", f"target={target}"])
    if extra_vars:
        for var in extra_vars:
            command.extend(["-e", var])

    try:
        subprocess.run(command, check=True)
        print("SUCCESS executing command:", " ".join(command))
    except subprocess.CalledProcessError as e:
        playbook_name = os.path.basename(playbook_path)
        error_msg = f"FAILED running playbook '{playbook_name}': {e}"
        print(error_msg)
        raise

# Fonction pour vérifier si une commande est sûre à exécuter
def is_command_safe(command):
    """
    Check if the command is safe to execute
    """
    dangerous_commands = ["rm", "sed", "dd", "mkfs", "wget", "curl", "apt", "yum", "dnf", "pip", "npm", "composer", "docker run", "docker stack rm", "docker service rm", "docker-compose", "kubectl", "helm", "rkt", "systemctl"]
    for dangerous_cmd in dangerous_commands:
        if dangerous_cmd in command:
            return False
    return True

# Fonction pour exécuter une commande sur l'hôte cible à l'aide d'Ansible
def run_command(command, target):
    """
    Run the command on the target host using ansible -m shell -a
    """
    if not is_command_safe(command):
        print(f"ERROR: Command '{command}' is not allowed.")
        return

    ansible_command = ["ansible", "-m", "shell", "-a", command, target]
    try:
        subprocess.run(ansible_command, check=True)
        print("SUCCESS executing command:", " ".join(ansible_command))
    except subprocess.CalledProcessError as e:
        print(f"FAILED executing command:", " ".join(ansible_command))
        raise

# Fonction pour analyser les arguments de ligne de commande
def parse_arguments():
    """
    Parse command line arguments
    """
    parser = argparse.ArgumentParser(description="Entry point for running ansible playbook in a container")
    parser.add_argument("--playbook", dest="playbook", help="Path to the playbook YAML file")
    parser.add_argument("--target", dest="target", help="Target host for the playbook")
    parser.add_argument("--extra_var", dest="extra_vars", action="append", help="Additional variables to pass to playbook in key=value format")
    parser.add_argument("--command", dest="command", help="Command to run on the target host using Ansible")
    return parser.parse_args()

# Fonction principale du script
def main():
    args = parse_arguments()
    
    run_regex_vars()  # Appel de la fonction run_regex_vars() au démarrage du conteneur
    
    if args.command:
        if not args.target:
            print("Error: Please provide the target host using either -t or --target option when specifying a command.")
            print("Usage:")
            print("  --target TARGET  Target host for the command")
            exit(1)
        
        run_command(args.command, args.target)
    elif args.playbook:
            if not args.target:
                print("Error: Please provide the target host using either -t or --target option.")
                exit(1)
            playbook_path = args.playbook
            try:
                run_playbook(playbook_path, args.target, args.extra_vars)
            except subprocess.CalledProcessError:
                exit(1)
    else:
        print("Error: Please provide either a playbook or a command.")
        print("Usage:")
        print("  --playbook PATH  Path to the playbook YAML file")
        print("  --command COMMAND  Command to run on the target host using Ansible")
        exit(1)

if __name__ == "__main__":
    main()
