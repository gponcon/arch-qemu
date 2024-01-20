#!/bin/sh

# By Guillaume Ponçon
# TODO: auto-detect host hardware limits (cpu, ram...)
# TODO: more env vars (pkg dir, fullscreen, etc.)

UEFI_BIOS_FILE='/usr/share/ovmf/x64/OVMF.fd'
DISPLAY_TYPE='std' # std or sdl

BIOS=''

while getopts "d:i:seh" option ;do
	case "${option}" in
		s)
			echo "-> Killing VMs..."
			killall --signal 15 --wait qemu-system-x86_64
			exit 0
			;;
		h)
			echo $(basename "$0")' -d disk.qcow [-i iso] [-e] [-h] [-s]'
			exit 0
			;;
		d)
			disk=${OPTARG}
			if [ -f "$disk" ] ;then
				DISK=$disk
			else
				echo "VM disk '$disk' file not found"
				exit 1
			fi
			;;
		i)
			image=${OPTARG}
			if [ -f $image ] ;then
				IMG=-'-boot order=d,menu=on -cdrom '$image
			else
				echo "ISO image file not found"
				exit 1
			fi
			;;
		e)
		    echo "Adding EFI bios..."
			if [ ! -f "$UEFI_BIOS_FILE" ] ;then
				echo "UEFI bios file '$UEFI_BIOS_FILE' not found."
				echo "Unable to boot with UEFI bios option."
				exit 1
			fi
			BIOS='-bios '"$UEFI_BIOS_FILE"
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

if [ -z "$disk" ]; then
	echo "Option -d (VM disk) is required."
	echo "Create a disk : qemu-img create -f qcow2 mydisk.cow 8G"
	exit 1
fi

# -display : gtk (good display) or sdl (immertion)

echo "-> Launching VM..."
qemu-system-x86_64 $IMG \
	-m 4G \
	-accel kvm \
	-cpu host \
	-smp cores=2,threads=2,sockets=1,maxcpus=4 \
	-display gtk \
	-device virtio-vga,edid=on,xres=1920,yres=1080 \
	-full-screen \
	-device virtio-net,netdev=net0 \
	-netdev user,id=net0,hostfwd=tcp::2222-:22 \
	-drive file=$DISK,format=qcow2,if=virtio \
	-device virtio-serial -chardev spicevmc,id=spicechannel0,name=vdagent \
	-fsdev local,security_model=mapped,id=fsdev0,path="/var/cache/pacman/pkg" \
	-device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=pkg \
	$BIOS
