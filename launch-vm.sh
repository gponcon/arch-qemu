#!/bin/sh

SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
VMS_DIR=$SCRIPT_DIR'/vms'
UEFI_BIOS_FILE='/usr/share/ovmf/x64/OVMF.fd'

set -o allexport
source "$SCRIPT_DIR"'/.env' set

while getopts "v:s:ie" option ;do
	case "${option}" in
		v)
			vm_name=${OPTARG}
			if [ "$vm_name" == 'example' ] ;then
  				echo "Do not use directly this file."
  				echo "Please copy 'example.sh' to 'my-vm-name.sh'."
  				echo "Usage : ./my-vm-name [-i] (-i flag = install mode)"
  				exit 1
			fi
			QCOW_FILE=$VMS_DIR'/'$vm_name'.qcow'
			if [ ! -f "$QCOW_FILE" ]; then
				if [ "$ARCH_VM_SIZE" == "" ] ;then
					echo "Arch VM size not specified"
					exit 1
				fi
  				echo "Building the new qcow image and switch to 'install' mode..."
  				qemu-img create -f qcow2 "$QCOW_FILE" $ARCH_VM_SIZE
  				INSTALL=1
			fi
			;;
		i)
			INSTALL=1
			;;
		s)
			ARCH_VM_SIZE=${OPTARG}
			;;
		e) 
			if [ ! -f "$UEFI_BIOS_FILE" ] ;then
				echo "UEFI bios file '$UEFI_BIOS_FILE' not found."
				echo "Unable to boot with UEFI bios option."
				exit 1
			fi
  			echo "UEFI mode..."
			BIOS='-e'
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
		:)
			echo "Argument required for -$OPTARG" >&2
			exit 1
			;;
		esac
done

if [ "$INSTALL" == "1" ] ;then
	if [ "$ARCH_VM_ISO" == "" ] ;then
  		ARCH_VM_ISO='archlinux.iso'
	fi
	if [ ! -f "$ARCH_VM_ISO" ] ;then
	  ARCH_VM_ISO="$SCRIPT_DIR"'/iso/'"$ARCH_VM_ISO"
	fi
	if [ ! -f "$ARCH_VM_ISO" ] ;then
  		echo "ISO file $SCRIPT_DIR"'/iso/'"$ARCH_VM_ISO not found."
  		echo "Please download iso file here https://archlinux.org/download/ and put it in 'iso' directory."
  		echo "You can also put the ISO file name in a .env file or export ARCH_VM_ISO."
  		echo "Installation aborted"
  		exit 1
	fi
	IMG='-i '"$ARCH_VM_ISO"
fi

"$SCRIPT_DIR/qemu.sh" -d "$QCOW_FILE" "$IMG" "$BIOS"
