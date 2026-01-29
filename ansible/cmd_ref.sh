# Run Initial Bootstrap Playbook for Bastion
ansible-playbook -i inventory.ini playbooks/bootstrap_bastion.yml
# Shutdown Proxmox Nodes Playbook
ansible-playbook -i inventory.ini playbooks/shutdown_proxmox_nodes.yml
# Test Connection
ansible -i inventory.ini proxmox_nodes -m ping
