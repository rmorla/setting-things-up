# install openssh

apt install openssh-server

vim /etc/ssh/sshd_config

service ssh restart

# add users 

## create user

adduser alice

## add public key access

cat alice_public_key.rsa >> /home/alice/.ssh/authorized_keys


# role play 1 -- brute force

SIEM notifications:

>> "Alice logged in successfully (IP: 192.168.23.7)" 

>> "get /etc/passwd"

>> "Alice edited /usrs/alice/doc2"

>> "Alice logged in successfully (IP: 88.97.25.1)" 


# role play 2 -- brute force

>> Alice complains of missing file

>> Alice says she did not login in the last few days

>> 



