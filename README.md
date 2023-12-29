# Arch Linux QEMU / KVM launcher

A qemu launcher optimized for Arch Linux.

## Prerequisites

```sh
sudo pacman -Syu qemu-desktop 
```

## Installation

```sh
git clone https://github.com/gponcon/arch-qemu.git
cd arch-qemu
```

## Arch VMs Usage

Download and [Arch Linux ISO](https://archlinux.org/download/) and put it in `iso/archlinux.iso`.

Copy the file **vms/example.sh** to vms/_my-vm_.sh (replace _my-vm_ by your virtual machine name) and edit it.

Launch your VM:

```sh
cd vms
cp example.sh my-vm.sh
./my-vm.sh
```

First time is install by default. To force re-install:

```sh
./my-vm.sh -i
```

## Optimized "qemu.sh" script usage

```sh
./qemu.sh -d <qcow2file> [-i isoFile] [-e] [-s]
```

* `-d` The VM image
* `-i` Arch Linux ISO file
* `-e` To simulate EFI bios
* `-s` Kill the current VM
* `-h` Help
