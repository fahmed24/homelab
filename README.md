# homelab

## Ansible
- server inventory stored in `./ansible/inventory.ini`
- make sure to include ssh private key path 
### Test Connection
```
ansible -i inventory.ini lxc_containers -m ping
```
