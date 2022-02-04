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

# GPU on a VM

First see: Setup -- GPU passthrough

## assign gpu to vm (and disable GPU vga - defaults to virtualization vga)

qm set 9001 -hostpci0 01:00,x-vga=off

# hide virtualization from guest (for NVIDIA drivers)

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

