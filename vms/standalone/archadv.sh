#!/bin/sh

OVMF_VARS_FILE='OVMF_VARS.fd'
OVMF_CODE_FILE='OVMF_CODE.fd'

if [ "$1" == "--reset" -a -d archadv ] ;then
  echo "Reset arch advanced VM..."
  rm -rf archadv
fi
if [ ! -d archadv ] ;then
  mkdir archadv
fi
if [ ! -f archadv/archadv1.qcow ] ;then
  qemu-img create -f qcow2 archadv/archadv1.qcow 1T
fi
if [ ! -f archadv/archadv2.qcow ] ;then
  qemu-img create -f qcow2 archadv/archadv2.qcow 500G
fi
if [ ! -f archadv/archadv3.qcow ] ;then
  qemu-img create -f qcow2 archadv/archadv3.qcow 2T
fi
if [ ! -f archadv/archadv4.qcow ] ;then
  qemu-img create -f qcow2 archadv/archadv4.qcow 200G
fi
if [ ! -f archadv/archadv5.qcow ] ;then
  qemu-img create -f qcow2 archadv/archadv5.qcow 1T
fi
if [ ! -f archadv/$OVMF_VARS_FILE ] ;then
  cp /usr/share/edk2/x64/$OVMF_VARS_FILE archadv/
fi

sudo cpupower frequency-set -g performance

qemu-system-x86_64 -boot order=d,menu=on -cdrom ~/src/arch-qemu/iso/archlinux-2024.01.01-x86_64.iso \
	-m 8G \
	-accel kvm \
	-cpu host \
	-smp cores=2,threads=2,sockets=1,maxcpus=4 \
	-display gtk \
	-device virtio-vga,edid=on,xres=1280,yres=720 \
	-device virtio-net,netdev=net0 \
	-netdev user,id=net0,hostfwd=tcp::2222-:22 \
	-drive file=archadv/archadv1.qcow,format=qcow2,if=virtio \
	-drive file=archadv/archadv2.qcow,format=qcow2,if=virtio \
	-drive file=archadv/archadv3.qcow,format=qcow2,if=virtio \
	-drive file=archadv/archadv4.qcow,format=qcow2,if=virtio \
	-drive file=archadv/archadv5.qcow,format=qcow2,if=virtio \
	-device virtio-serial -chardev spicevmc,id=spicechannel0,name=vdagent \
	-fsdev local,security_model=mapped,id=fsdev0,path="/var/cache/pacman/pkg" \
	-device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=pkg \
	-machine pc-q35-2.5 \
	-device intel-iommu \
	-drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/x64/$OVMF_CODE_FILE \
	-drive if=pflash,format=raw,file=archadv/$OVMF_VARS_FILE
