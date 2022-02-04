
# Setup tensorflow on docker

https://www.tensorflow.org/install/docker
https://docs.docker.com/engine/install/ubuntu/

## allow the proxmox vm to get access to AVX instructions (for tensorflow)

vi /etc/pve/qemu-server/9001.conf
>> cpu: host

# docker 

## install
sudo apt-get update

sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io

sudo docker run hello-world

## docker-compose (without swarm)

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

## allow non-sudo usage

https://docs.docker.com/engine/install/linux-postinstall/

- Manage Docker as a non-root user (need to enter new terminal to have non-root 'docker ps' access)

sudo usermod -aG docker $USER

- Configure Docker to start on boot

sudo systemctl enable docker.service

sudo systemctl enable containerd.service

## registry access

### http registry (insecure)

edit /etc/docker/daemon.json, add registry ip and port:
>> {
>>  "insecure-registries" : ["10.1.1.1:5000"]
>> }
>> 
### https registry (secure)

copy registry certificate to /etc/docker/certs.d/ using the ip and port number in the folder and filename (use \: to escape the semicolon for the port)
>> /etc/docker/certs.d/1.1.1.1\:5000/registry.crt

## swarm

docker swarm init


# GPU on docker

If you didn't install it when configuring the GPU passthrough:
https://www.tensorflow.org/install/gpu

NVIDIA docker support:
https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker

## docker tensorflow

docker pull tensorflow/tensorflow

docker run --gpus=all -it --rm tensorflow/tensorflow python -c "import tensorflow as tf; print(tf.reduce_sum(tf.random.normal([1000, 1000])))"

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
