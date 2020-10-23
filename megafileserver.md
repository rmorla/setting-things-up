# MegaFileServer

## install openssh

apt install openssh-server

vim /etc/ssh/sshd_config

service ssh restart

## add users 

### create users

adduser alice

adduser bob

### add public key access

cat alice_public_key.rsa >> /home/alice/.ssh/authorized_keys

cat bob_public_key.rsa >> /home/bob/.ssh/authorized_keys


## role play 

### role play 1 -- brute force

Someone bruteforced Alice's password.

>> "Alice logged in successfully (IP: 192.168.23.7)" 

>> "get /etc/passwd"

>> "Alice edited /home/alice/doc2"

>> "Alice logged in successfully (IP: 88.97.25.1)" 

### role play 2 -- privilege escalation

Bob deleted Alice's file.

>> Alice complains of missing file "/home/alice/doc1"

>> Alice says she did not login in the last few days

>> Bob logged in and deleted Alice's file

### role play 3 -- MITM

Bob performed a mitm on the openssh server

>> Alice complains about not being able to access the server 

>> Server is up, no errors

>> Alice details error: "WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!"

>> Key fingerprint shown to Alice is different from the server's, confirm MITM

>> Check for ARP poisoning

>> Take down MITM server

### role play 4 -- exfiltration / USB

Bob managed to connect a USB device on the server

>> Alice's document /users/alice/doc3 appeared on the internet

>> Alice did not transfer the document out of the server

>> Bob did not login in the last few days

>> USB attached to server does 'sudo su' 

>> root user copies the file to an external server








