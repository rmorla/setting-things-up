# Setup

## 'flash' the usb 

https://pve.proxmox.com/wiki/Prepare_Installation_Media

## setup BIOS

Boot into BIOS. CPU / Intel VMX Virtualization Technology.

## GPU passthrough

### use internal graphics as primary display

Boot into BIOS. Go to Graphics Configuration, Primary Display, choose IGFX / iGPU for internal graphics.

### enable VT-x on the motherboard

Boot into BIOS. Enable VT-x (System Agent).

### kernel enable IOMMU

cd /etc/default/grub.d/

vi iommu.cfg
>> GRUB_CMDLINE_LINUX_DEFAULT="${GRUB_CMDLINE_LINUX_DEFAULT} intel_iommu=on"

update-grub

reboot

## Proxmox apt update

rm /etc/apt/sources.list.d/pve-enterprise.list

echo "deb http://download.proxmox.com/debian buster pve-no-subscription" >> /etc/apt/sources.list

apt update

apt upgrade

## Cluster

https://pve.proxmox.com/wiki/Cluster_Manager

edit /etc/hosts or other means for name resolution

on the cluster head:

$ pvecm create clustername

on the node that you want to join the cluster (warning: will delete images on new node)

$ pvecm add IPADDR_CLUSTERHEAD


# GPU on a VM

First see: Setup -- GPU passthrough

## assign gpu to vm (and disable GPU vga - defaults to virtualization vga)

qm set 9001 -hostpci0 01:00,x-vga=off

## hide virtualization from guest (for NVIDIA drivers)

vi /etc/pve/qemu-server/9001.conf
>> cpu: host,hidden=1

## install NVIDIA drivers on guest

https://www.tensorflow.org/install/gpu


ubuntu 20.04

$ sudo apt update

$ sudo apt install nvidia-driver-460

$ sudo apt install nvidia-utils-460


# USB device on a VM

https://pve.proxmox.com/wiki/USB_Devices_in_Virtual_Machines

usb-devices

host=8-2 => 8: bus, 2 cnt -- this can be seen on the output of usb-devices

>>T:  Bus=08 Lev=01 Prnt=01 Port=01 Cnt=02 Dev#=  8 Spd=12  MxCh= 0

cat /sys/bus/usb/devices/usb8/8-1/manufacturer


vi /etc/pve/qemu-server/9001.conf
>> usb0: host=8-2

# Disk management

https://pve.proxmox.com/wiki/Storage

## Create volume and assign to VM

vm 9001, 150GB

### proxmox

pvesm alloc local-lvm 9001 vm-9001-diskname 150G

pvesm list local-lvm
pvesm path local-lvm:vm-9001-diskname

vi /etc/pve/qemu-server/9001.conf
>> scsi1: local-lvm:vm-9001-diskname.raw,size=150G

### guest

sudo parted /dev/sdb
mklabel msdos
mkpart
primary, ext4, 0, 150G, ignore
quit

sudo mkfs.ext4 /dev/sdb1

sudo blkid
>>> /dev/sdb1: UUID="b22a9200-5665-4eb7-b9b5-1a031e0fe525" TYPE="ext4" PARTUUID="d5119a46-01"
> use UUID on fstab

sudo mkdir /mounted_folder

sudo vim /etc/fstab
>> UUID=b22a9200-5665-4eb7-b9b5-1a031e0fe525 /mounted_folder ext4  defaults    0    0

sudo mount /mounted_folder

## Assign a whole disk to a VM (disk/by-id)

https://pve.proxmox.com/wiki/Passthrough_Physical_Disk_to_Virtual_Machine_(VM)

find disk id
>> ls -sal /dev/disk/by-id

assign disk xxxxx to VM nnn
>> qm set nnn -scsi1 /dev/disk/by-id/xxxxx-disk-id-xxxxxxx

## lvm extend

check VG name and free size
>> sudo vgdisplay

extend VG size (check which lv under /dev/ubuntu-vg)
>> sudo lvextend -l +6015 /dev/ubuntu-vg/ubuntu-lv

resize filesystem
>> sudo resize2fs /dev/ubuntu-vg/ubuntu-lv

check new size
>> df

## resize disks

https://pve.proxmox.com/wiki/Resize_disks

fdisk -l 

parted /dev/sda

print

Fix/Ignore? F

resizepart 3 100%

pvresize

then lvextend (see above)

## import proxmox disk from another host

rename: find vg_UUID, then change name
> vgdisplay
> 
> vgrename vg_UUID new_vg_name

deactivate/activate vg -- this will create entries under /dev/vg
> vgchange -an new_vg_name
>
> vgchange -ay new_vg_name

add proxmox storage
> nano /etc/pve/storage.cfg 
> 
>> lvmthin: local-lvm-newname
>> 
>>        thinpool data
>>        
>>        vgname new_vg_name
>>        
>>        content rootdir,images



# VM from cloudimage

https://pve.proxmox.com/wiki/Cloud-Init_Support

Download image from distribution

- https://cloud-images.ubuntu.com/ 

- https://cloud.debian.org/images/cloud/


>> wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img

Create VM

>> qm create 9001 -memory 2048 -cores 2 -cpu host -onboot no  -ciuser theuser -sshkeys ~/test.rsa.pub -ipconfig0 ip=10.1.1.111/24,gw=10.1.1.1 -net0 "virtio,bridge=vmbr0"

Import cloudimage disk into VM

>> qm importdisk 9001 focal-server-cloudimg-amd64.img local-lvm

>> qm set 9001 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9001-disk-0 --boot c --bootdisk scsi0 --ide2 local-lvm:cloudinit

>> qm resize 9001 scsi0 +100G

Start, stop

>> qm start 9001

>> qm stop 9001

Destroy vm

>> qm destroy 9001

# If you're venturing on the Windows path...

https://pve.proxmox.com/wiki/Windows_VirtIO_Drivers
