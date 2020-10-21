# Proxmox

## 'flash' the usb 

https://pve.proxmox.com/wiki/Prepare_Installation_Media

## GPU passthrough

### enable VT-x on the motherboard

Boot into BIOS configuration and change virtualization setting.

### kernel enable IOMMU

cd /etc/default/grub.d/

vi iommu.cfg
>> GRUB_CMDLINE_LINUX_DEFAULT="${GRUB_CMDLINE_LINUX_DEFAULT} intel_iommu=on"

reboot

### assign gpu to vm (and disable GPU vga - defaults to virtualization vga)

qm set 9001 -hostpci0 01:00,x-vga=off

### hide virtualization from guest (for NVIDIA drivers)

vi /etc/pve/qemu-server/9001.conf
>> cpu: host,hidden=1

### install NVIDIA drivers on guest

https://www.tensorflow.org/install/gpu

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

Configure Docker to start on boot

## GPU on docker

If you didn't install it when configuring the GPU passthrough:
https://www.tensorflow.org/install/gpu

NVIDIA docker support:
https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker

## docker tensorflow

docker pull tensorflow/tensorflow

docker run -it --rm tensorflow/tensorflow python -c "import tensorflow as tf; print(tf.reduce_sum(tf.random.normal([1000, 1000])))"

## customized dockerfile

docker-tensorflow-1.15.4-py3-jupyter

>> FROM tensorflow/tensorflow:1.15.4-py3-jupyter

>> RUN pip install --upgrade tldextract

## see networktools dockerfile

