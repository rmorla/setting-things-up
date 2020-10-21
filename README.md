# Proxmox

## GPU passthrough


## Adding disk (vm 9001, 150GB)

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
