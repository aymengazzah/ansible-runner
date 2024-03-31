#!/bin/bash

# Function to display error messages and exit
function display_error {
    echo "$(date +'%Y-%m-%d %H:%M:%S') ERROR: $1"
    exit 1
}

# Function to display success messages
function display_success {
    echo "$(date +'%Y-%m-%d %H:%M:%S') SUCCESS: $1"
}

# Function for logging with timestamp
logger() {
    local log="$1"
    local is_verbose_log="${2:-false}"

    if [[ "$is_verbose_log" == "true" && "$verbose" == "true" || "$is_verbose_log" == "false" ]]; then
        echo "$(date +'%Y-%m-%d %H:%M:%S') $log"
    fi
}

# Function to replace variables in ansible.cfg
replace_variables() {
    local ansible_cfg="/etc/ansible/ansible.cfg"
    logger "Replacing variables in ansible.cfg..."
    sed -i "s|%%ANSIBLE_HOST_KEY_CHECKING%%|${ANSIBLE_HOST_KEY_CHECKING}|g" $ansible_cfg || display_error "Failed to replace ANSIBLE_HOST_KEY_CHECKING in ansible.cfg"
    sed -i "s|%%ANSIBLE_USERNAME%%|${ANSIBLE_USERNAME}|g" $ansible_cfg || display_error "Failed to replace ANSIBLE_USERNAME in ansible.cfg"
    sed -i "s|%%ANSIBLE_INVENTORY_FILE%%|${ANSIBLE_INVENTORY_FILE}|g" $ansible_cfg || display_error "Failed to replace ANSIBLE_INVENTORY_FILE in ansible.cfg"
    sed -i "s|%%ANSIBLE_ROLES_PATH%%|${ANSIBLE_ROLES_PATH}|g" $ansible_cfg || display_error "Failed to replace ANSIBLE_ROLES_PATH in ansible.cfg"
    sed -i "s|%%ANSIBLE_VAULT_PASSWORD_FILE%%|${ANSIBLE_VAULT_PASSWORD_FILE}|g" $ansible_cfg || display_error "Failed to replace ANSIBLE_VAULT_PASSWORD_FILE in ansible.cfg"
    sed -i "s|%%ANSIBLE_PRIV_KEY_FILE%%|${ANSIBLE_PRIV_KEY_FILE}|g" $ansible_cfg || display_error "Failed to replace ANSIBLE_PRIV_KEY_FILE in ansible.cfg"
    display_success "Variables in ansible.cfg have been replaced successfully"
}

# Set default values for variables if not provided
set_default_variables() {
    : ${ANSIBLE_HOST_KEY_CHECKING:="False"}
    : ${ANSIBLE_USERNAME:="ansible"}
    : ${ANSIBLE_INVENTORY_FILE:="/ansible-project/inventory/hosts.yml"}
    : ${ANSIBLE_ROLES_PATH:="/ansible-project/roles"}
    : ${ANSIBLE_VAULT_PASSWORD_FILE:="/ansible_password"}
    : ${ANSIBLE_PRIV_KEY_FILE:="/ansible_ssh_key"}

    # Validate ANSIBLE_HOST_KEY_CHECKING value
    if [[ "$ANSIBLE_HOST_KEY_CHECKING" != "True" && "$ANSIBLE_HOST_KEY_CHECKING" != "False" ]]; then
        display_error "ANSIBLE_HOST_KEY_CHECKING must be set to 'True' or 'False'"
    fi
}

# Execute functions
echo ""
set_default_variables
replace_variables
logger "cat /etc/ansible/ansible.cfg:" 
cat /etc/ansible/ansible.cfg
echo ""
logger "starting /runner/entrypoint.py and executing args options"
echo ""
