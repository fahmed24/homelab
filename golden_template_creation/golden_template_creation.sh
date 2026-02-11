#!/bin/bash

# Different ID per Proxmox Nodes: 9000 and 9001
VMID=9001
VMNAME="ubuntu-2204-cloud-template"
STORAGE="local-lvm"
# Using a Ubuntu Cloud Image ready from Canonical
IMG="jammy-server-cloudimg-amd64.img"

# Create empty VM
# Creating on Internal LAN and using required virtio-scsi-pci drivers (ubuntu requirement)
qm create $VMID --name $VMNAME --memory 2048 --cores 2 --net0 virtio,bridge=vmbr1, --scsihw virtio-scsi-pci

# Import disk
qm importdisk $VMID $IMG $STORAGE

# Attach disk + cloud-init
qm set $VMID --scsi0 ${STORAGE}:vm-${VMID}-disk-0
qm set $VMID --ide2 ${STORAGE}:cloudinit

# Boot + console
qm set $VMID --boot order=scsi0

# Convert to template
qm template $VMID
