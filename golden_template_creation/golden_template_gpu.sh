#!/bin/bash
# Different ID per Proxmox Nodes: 9000 and 9001
VMID=9001
VMNAME="UBUNTU-2204-CLOUD-TEMPLATE-GPU-SB"
STORAGE="local-lvm"
# Using a Ubuntu Cloud Image ready from Canonical
IMG="jammy-server-cloudimg-amd64.img"

# Create empty VM with OVMF (UEFI) and Q35 machine type
qm create $VMID --name $VMNAME --memory 2048 --cores 2 \
  --net0 virtio,bridge=vmbr1 \
  --scsihw virtio-scsi-single \
  --bios ovmf \
  --machine q35

# Import disk
qm importdisk $VMID $IMG $STORAGE

# Attach disk + cloud-init
qm set $VMID --ide2 ${STORAGE}:cloudinit
qm set $VMID --scsi0 ${STORAGE}:vm-${VMID}-disk-0

# Add EFI disk
qm set $VMID --efidisk0 ${STORAGE}:1,efitype=4m,pre-enrolled-keys=1

# Boot order
qm set $VMID --boot order=scsi0

# Convert to template
qm template $VMID
