==========================================================
  OpenStack Grizzly Install Guide
==========================================================

:Version: 2.0
:Source: https://github.com/mseknibilel/OpenStack-Grizzly-Install-Guide
:Keywords: Single node OpenStack, Grizzly, Quantum, Nova, Keystone, Glance, Horizon, Cinder, OpenVSwitch, KVM, Ubuntu Server 12.04 (64 bits).

Authors
==========

`Bilel Msekni <http://www.linkedin.com/profile/view?id=136237741&trk=tab_pro>`_ <bilel.msekni@gmail.com> 

Contributors
==========

=================================================== =======================================================

 Houssem Medhioub <houssem.medhioub@it-sudparis.eu> Djamal Zeghlache <djamal.zeghlache@telecom-sudparis.eu>
 Sandeep Raman  <sandeepr@hp.com>                   Sam Stoelinga <sammiestoel@gmail.com>
 Andy Edmonds <edmo@zhaw.ch>
 
=================================================== =======================================================

Wana contribute ? Read the guide, send your contribution and get your name listed ;)

Table of Contents
=================

::

  0. What is it?
  1. Requirements
  2. Preparing your node
  3. Keystone
  4. Glance
  5. Quantum
  6. Nova
  7. Cinder
  8. Horizon
  9. Your first VM
  10. Licensing
  11. Contacts
  12. Acknowledgement
  13. Credits
  14. To do

0. What is it?
==============

OpenStack Grizzly Install Guide is an easy and tested way to create your own OpenStack platform. 

If you like it, don't forget to star it !

Status: Stable


1. Requirements
====================

:Node Role: NICs
:Single Node: eth0 (10.10.100.51), eth1 (192.168.100.51)

**Note 1:** Multi node deployment is available on the OVS_MultiNode branch.

**Note 2:** Always use dpkg -s <packagename> to make sure you are using grizzly packages (version : 2013.1)

**Note 3:** This is my current network architecture.

.. image:: http://i.imgur.com/58Dr48n.jpg

2. Preparing your node
===============

2.1. Preparing Ubuntu
-----------------

* After you install Ubuntu 12.04 Server 64bits, Go in sudo mode and don't leave it until the end of this guide::

   sudo su

* Add Grizzly repositories::

   apt-get install ubuntu-cloud-keyring python-software-properties software-properties-common python-keyring
   echo deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/grizzly main >> /etc/apt/sources.list.d/grizzly.list

* Update your system::

   apt-get update
   apt-get upgrade
   apt-get dist-upgrade

2.2.Networking
------------

* Only one NIC should have an internet access::

   #For Exposing OpenStack API over the internet
   auto eth1
   iface eth1 inet static
   address 192.168.100.51
   netmask 255.255.255.0
   gateway 192.168.100.1
   dns-nameservers 8.8.8.8

   #Not internet connected(used for OpenStack management)
   auto eth0
   iface eth0 inet static
   address 10.10.100.51
   netmask 255.255.255.0

* Restart the networking service::

   service networking restart

2.3. MySQL & RabbitMQ
------------

* Install MySQL::

   apt-get install -y mysql-server python-mysqldb

* Configure mysql to accept all incoming requests::

   sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf
   service mysql restart

* Install RabbitMQ::

   apt-get install -y rabbitmq-server 

* Install NTP service::

   apt-get install -y ntp
 
2.5. Others
-------------------

* Install other services::

   apt-get install -y vlan bridge-utils

* Enable IP_Forwarding::

   sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf

   # To save you from rebooting, perform the following
   sysctl net.ipv4.ip_forward=1

3. Keystone
=============

* Start by the keystone packages::

   apt-get install -y keystone

* Verify your keystone is running::

   service keystone status

* Create a new MySQL database for keystone::

   mysql -u root -p
   CREATE DATABASE keystone;
   GRANT ALL ON keystone.* TO 'keystoneUser'@'%' IDENTIFIED BY 'keystonePass';
   quit;

* Adapt the connection attribute in the /etc/keystone/keystone.conf to the new database::

   connection = mysql://keystoneUser:keystonePass@10.10.100.51/keystone

* Restart the identity service then synchronize the database::

   service keystone restart
   keystone-manage db_sync

* Fill up the keystone database using the two scripts available in the `Scripts folder <https://github.com/mseknibilel/OpenStack-Grizzly-Install-Guide/tree/master/KeystoneScripts>`_ of this git repository::

   #Modify the HOST_IP and HOST_IP_EXT variables before executing the scripts
   
   wget https://raw.github.com/mseknibilel/OpenStack-Grizzly-Install-Guide/OVS_SingleNode/KeystoneScripts/keystone_basic.sh
   wget https://raw.github.com/mseknibilel/OpenStack-Grizzly-Install-Guide/OVS_SingleNode/KeystoneScripts/keystone_endpoints_basic.sh

   chmod +x keystone_basic.sh
   chmod +x keystone_endpoints_basic.sh

   ./keystone_basic.sh
   ./keystone_endpoints_basic.sh

* Create a simple credential file and load it so you won't be bothered later::

   nano creds

   #Paste the following:
   export OS_TENANT_NAME=admin
   export OS_USERNAME=admin
   export OS_PASSWORD=admin_pass
   export OS_AUTH_URL="http://192.168.100.51:5000/v2.0/"

   # Load it:
   source creds

* To test Keystone, we use a simple CLI command::

   keystone user-list

4. Glance
=============

* We Move now to Glance installation::

   apt-get install -y glance

* Verify your glance services are running::

   service glance-api status
   service glance-registry status

* Create a new MySQL database for Glance::

   mysql -u root -p
   CREATE DATABASE glance;
   GRANT ALL ON glance.* TO 'glanceUser'@'%' IDENTIFIED BY 'glancePass';
   quit;

* Update /etc/glance/glance-api-paste.ini with::

   [filter:authtoken]
   paste.filter_factory = keystoneclient.middleware.auth_token:filter_factory
   delay_auth_decision = true
   auth_host = 10.10.100.51
   auth_port = 35357
   auth_protocol = http
   admin_tenant_name = service
   admin_user = glance
   admin_password = service_pass

* Update the /etc/glance/glance-registry-paste.ini with::

   [filter:authtoken]
   paste.filter_factory = keystoneclient.middleware.auth_token:filter_factory
   auth_host = 10.10.100.51
   auth_port = 35357
   auth_protocol = http
   admin_tenant_name = service
   admin_user = glance
   admin_password = service_pass

* Update /etc/glance/glance-api.conf with::

   sql_connection = mysql://glanceUser:glancePass@10.10.100.51/glance

* And::

   [paste_deploy]
   flavor = keystone
   
* Update the /etc/glance/glance-registry.conf with::

   sql_connection = mysql://glanceUser:glancePass@10.10.100.51/glance

* And::

   [paste_deploy]
   flavor = keystone

* Restart the glance-api and glance-registry services::

   service glance-api restart; service glance-registry restart

* Synchronize the glance database::

   glance-manage db_sync

* Restart the services again to take into account the new modifications::

   service glance-registry restart; service glance-api restart

* To test Glance, upload the cirros cloud image directly from the internet::

   glance image-create --name myFirstImage --is-public true --container-format bare --disk-format qcow2 --location https://launchpad.net/cirros/trunk/0.3.0/+download/cirros-0.3.0-x86_64-disk.img

* Now list the image to see what you have just uploaded::

   glance image-list

5. Quantum
=============

5.1. OpenVSwitch
------------------

* Install the openVSwitch::

   apt-get install -y openvswitch-switch openvswitch-datapath-dkms

* Create the bridges::

   #br-int will be used for VM integration	
   ovs-vsctl add-br br-int

   #br-ex is used to make to access the internet (not covered in this guide)
   ovs-vsctl add-br br-ex

5.1.1. OpenVSwitch (Part2, Optional)
------------------

* This will guide you to setting up the br-ex interface. Edit the eth1 in /etc/network/interfaces to become like this::

   # VM internet Access 
   auto eth1 
   iface eth1 inet manual 
   up ifconfig $IFACE 0.0.0.0 up 
   up ip link set $IFACE promisc on 
   down ip link set $IFACE promisc off 
   down ifconfig $IFACE down 

* Add the eth1 to the br-ex::

   #Internet connectivity will be lost after this step but this won't affect OpenStack's work
   ovs-vsctl add-port br-ex eth1

* Optional, If you want to get internet connection back, you can assign the eth1's IP address to the br-ex in the /etc/network/interfaces file::

   auto br-ex
   iface br-ex inet static
   address 192.168.100.51
   netmask 255.255.255.0
   gateway 192.168.100.1
   dns-nameservers 8.8.8.8

* Note to VirtualBox users, you will likely be using host-only adapters for the private networking. You need to provide a route out of the host-only network to contact the outside world; egress is not supported by host-only adapters. This can be done by routing traffic from br-ex to an additional NAT'ed adapter that you can add. Run these commands (where NAT'ed adapter is eth2)::

   iptables --table nat --append POSTROUTING --out-interface eth2 -j MASQUERADE
   iptables --append FORWARD --in-interface br-ex -j ACCEPT

To create the quantum external network you should then follow `the multinode guide's section 5 <https://github.com/mseknibilel/OpenStack-Grizzly-Install-Guide/blob/OVS_MultiNode/OpenStack_Grizzly_Install_Guide.rst#5-your-first-vm>`_ on this. Note: when creating the external network, be sure to set the gateway IP to 192.168.100.51

