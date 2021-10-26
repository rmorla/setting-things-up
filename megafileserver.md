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


## role play 2020

### role play 20.1 -- brute force

Someone bruteforced Alice's password.

>> "Alice logged in successfully (IP: 192.168.23.7)" 

>> "get /etc/passwd"

>> "Alice edited /home/alice/doc2"

>> "Alice logged in successfully (IP: 88.97.25.1)" 

### role play 20.2 -- privilege escalation

Bob deleted Alice's file.

>> Alice complains of missing file "/home/alice/doc1"

>> Alice says she did not login in the last few days

>> Bob logged in and deleted Alice's file

### role play 20.3 -- MITM

Bob performed a mitm on the openssh server

>> Alice complains about not being able to access the server 

>> Server is up, no errors

>> Alice details error: "WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!"

>> Key fingerprint shown to Alice is different from the server's, confirm MITM

>> Check for ARP poisoning

>> Take down MITM server

### role play 20.4 -- exfiltration / USB

Bob managed to connect a USB device on the server

>> Alice's document /users/alice/doc3 appeared on the internet

>> Alice did not transfer the document out of the server

>> Bob did not login in the last few days

>> USB attached to server does 'sudo su' 

>> root user copies the file to an external server


## role play 2021

### role play 21.1 -- bruteforce / Mēris / Dirty Cow (thx D.Maia)

Brute force attack on Bob's account from a list of IPs that show up in shodan.io and associated to mikrotik and a botnet -- https://www.shodan.io/search?query=mikrotik

>> Failed Login Attempt from IP 87.227.137.6 for Account "Bob" at 12:02:47 

>> Failed Login Attempt from IP 220.175.182.171 for Account "Bob" at 12:02:48 

>> Failed Login Attempt from IP 213.192.39.63 for Account "Bob" at 12:02:50

Other IPs 87.227.137.6 220.175.182.171 213.192.39.63 45.188.64.128 103.92.218.4

No VPN used by Bob. No successful login at the moment.

If no action taken by the SOC (like blocking Bob's account, changing password, or something else to prevent the brute force attack:

>> Dirty Cow attack to elevate Bob account's privileges to root

>> Attack Alice or the service

### role play 21.2 -- ssh vulnerability (need details here)

The specific version of the ssh server has a vulnerability that allows an non-authenticated user to e.g. add files to some user account

>> Alice complains because some files appeared in her home folder

>> Alice was not logged in at the time the file was created

>> User id that created the file is root/system

>> ssh log files confirm exploit

### role play 21.3 -- TCP SYN flood attack

>> Alice complains she can't access the server
 
>> The server responds to pings but not to ssh

>> Existing/prior ssh sessions work without any problem

>> Establishing new connections is very hard

>> tcpdump logs show SYN flood

>> mitigate attack ??

### role play 21.4 -- user awareness

Alice's laptop left unattended and logged in while Alice uses the rest room.

>> Alice complains she can't access the server

>> The server is up and everyone except Alice is happy

>> Server logs show Alice changed password at 12:51

>> Alice was using the rest room between 12:50 and 12:52 so she didn't do it

>> Alice has only one ssh connection to the server from her favourite coffee shop IP's address, no signs of privilege escalation

>> Someone typed passwd in Alice's laptop while she wasn't attending to the lapto and her password

