#!/bin/sh

# Disk size
ARCH_VM_SIZE='8G'

# UEFI Simulation
ARCH_VM_EFI=1

VMS_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
VM_NAME=`echo $(basename "$0") | sed 's/\.sh$//'`

if [ ! -e "$VMS_DIR"'/../launch-vm.sh' ] ;then
  echo "launch-vm.sh file not found, please launch this file in 'vms' directory."
  exit 1
fi

if [ "$VM_INSTALL" == "" ] ;then
  if [ "$1" == '-i' ] ;then
    VM_INSTALL='-i'
  fi
fi

if [ $ARCH_VM_EFI -eq 1 ] ;then
  VM_EFI='-e'
fi

sh "$VMS_DIR/../launch-vm.sh" -v "$VM_NAME" -s "$ARCH_VM_SIZE" $VM_INSTALL $VM_EFI  
