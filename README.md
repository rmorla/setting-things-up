# Proxmox

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

### assign gpu to vm (and disable GPU vga - defaults to virtualization vga)

qm set 9001 -hostpci0 01:00,x-vga=off

### hide virtualization from guest (for NVIDIA drivers)

vi /etc/pve/qemu-server/9001.conf
>> cpu: host,hidden=1

### install NVIDIA drivers on guest

https://www.tensorflow.org/install/gpu

## USB passthrough

https://pve.proxmox.com/wiki/USB_Devices_in_Virtual_Machines

usb-devices

host=8-2 => 8: bus, 2 cnt -- this can be seen on the output of usb-devices

>>T:  Bus=08 Lev=01 Prnt=01 Port=01 Cnt=02 Dev#=  8 Spd=12  MxCh= 0

vi /etc/pve/qemu-server/9001.conf
>> usb0: host=8-2



## Adding disk (vm 9001, 150GB)

https://pve.proxmox.com/wiki/Storage

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

### disk/by-id

https://pve.proxmox.com/wiki/Passthrough_Physical_Disk_to_Virtual_Machine_(VM)

find disk id
>> ls -sal /dev/disk/by-id

assign disk xxxxx to VM nnn
>> qm set nnn -scsi1 /dev/disk/by-id/xxxxx-disk-id-xxxxxxx

### lvm extend

check VG name and free size
>> sudo vgdisplay

extend VG size (check which lv under /dev/ubuntu-vg)
>> sudo lvextend -l +6015 /dev/ubuntu-vg/ubuntu-lv

resize filesystem
>> sudo resize2fs /dev/ubuntu-vg/ubuntu-lv

check new size
>> df

### resize disks

https://pve.proxmox.com/wiki/Resize_disks

fdisk -l 

parted /dev/sda

print

Fix/Ignore? F

resizepart 3 100%


## importing proxmox disk from another host

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


## cloud init

> wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img

> qm importdisk vmid focal-server-cloudimg-amd64.img local-lvm

add cloudinit drive

expand disc to target size (proxmox gui)

edit vm configs /etc/pve/qemu-server/vmid.conf


## setting up a cluster

https://pve.proxmox.com/wiki/Cluster_Manager

edit /etc/hosts or other means for name resolution

on the cluster head:

$ pvecm create clustername

on the node that you want to join the cluster (warning: will delete images on new node)

$ pvecm add IPADDR_CLUSTERHEAD


# Setting up tensorflow on docker

https://www.tensorflow.org/install/docker
https://docs.docker.com/engine/install/ubuntu/

## allow the proxmox vm to get access to AVX instructions (for tensorflow)

vi /etc/pve/qemu-server/9001.conf
>> cpu: host

## docker 

### install
sudo apt-get update

sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io

sudo docker run hello-world

### allow non-sudo usage

https://docs.docker.com/engine/install/linux-postinstall/

Manage Docker as a non-root user

> sudo usermod -aG docker $USER

Configure Docker to start on boot

### registry access

#### http registry (insecure)

edit /etc/docker/daemon.json, add registry ip and port:
>> {
>>  "insecure-registries" : ["10.1.1.1:5000"]
>> }
>> 
#### https registry (secure)

copy registry certificate to /etc/docker/certs.d/ using the ip and port number in the folder and filename (use \: to escape the semicolon for the port)
>> /etc/docker/certs.d/1.1.1.1\:5000/registry.crt

## GPU on docker

If you didn't install it when configuring the GPU passthrough:
https://www.tensorflow.org/install/gpu

NVIDIA docker support:
https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker

## docker tensorflow

docker pull tensorflow/tensorflow

docker run -it --rm tensorflow/tensorflow python -c "import tensorflow as tf; print(tf.reduce_sum(tf.random.normal([1000, 1000])))"

## customized dockerfile

### create dockerfile 

docker-tensorflow-1.15.4-py3-jupyter

>> FROM tensorflow/tensorflow:1.15.4-py3-jupyter

>> RUN pip install --upgrade tldextract

###  another example 

see file: tensorflow-networktools

### build container image

docker build -t tf-1.15.4-py3-jupyter-networktools - < tensorflow-networktools

### run 

docker run -d --rm --name mycontainername --mount type=bind,source=/host/path,target=/container/path -p 8888:8888 tf-1.15.4-py3-jupyter-networktools 

docker exec mycontainername jupyter notebook list


# If you're venturing on the Windows path...

https://pve.proxmox.com/wiki/Windows_VirtIO_Drivers
