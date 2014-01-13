==========================================================
  OpenStack Havana Install Guide
==========================================================

:Version: 1.0
:Source: https://github.com/fornyx/OpenStack-Havana-Install-Guide
:Keywords: Single Multi node OpenStack, Havana, Neutron, Nova, Keystone, Glance, Horizon, Cinder, OpenVSwitch, KVM, Ubuntu Server 12.04 (64 bits).

Authors
==========

`Marco Fornaro <http://www.linkedin.com/profile/view?id=49858164>`_ <marco.fornaro@gmail.com> 

Contributors
==========

===================================================

 no contributors at the moment..:-(...
 ...BUT this guide owe quite a lot from:
 `Bilel Msekni <https://github.com/mseknibilel/OpenStack-Grizzly-Install-Guide>`_ 
  And I like to start this guide thanking him for his work :-)

===================================================

Contributors are welcome! Read this guide, send your contribution and get your name listed :-)

Table of Contents
=================

::

  0. What is it?
  1. Requirements
  2. Preparing your node
  3. Keystone
  4. Glance
  5. Neutron
  6. Nova
  7. Cinder
  8. Horizon
  9. Your first VM
  10. Adding a Compute Node
  11. Licensing
  12. Contacts
  14. Credits
  15. To do

0. What is it?
==============

OpenStack Havana Install Guide is projected to be a step-by-step "as easy as possible" guide and has been heavily tested.

It aims to be one of the simplest way to get an OpenStack instance with advanced network components up and running. 

If you like it, don't forget to star it !

Status: Stable


1. Requirements
====================

:Node Role: Controller, Network Controller and Compute Node
:Nics: eth0 (10.10.10.51), eth1 (192.168.1.251)

**Note 1:** Multi node deployment is currently available in this guide, see "10. Adding a Compute Node".

**Note 2:** We suggest to use dpkg -s <packagename> to make sure you are using Havana packages (you should see version : 2013.2)

**Note 3:** This is a simple test/demo installation, and so the password policy has been VERY simplified: we use "openstacktest" as default password (see further)

2. Preparing your node
===============

2.1. Preparing Ubuntu
-----------------

* After you install Ubuntu 12.04 Server 64bits, Go in sudo mode and don't leave it until the end of this guide::

   sudo su

* Add Havana repositories::

   apt-get install ubuntu-cloud-keyring python-software-properties software-properties-common python-keyring
   echo deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-proposed/havana main >> /etc/apt/sources.list.d/havana.list

* Update your system::

   apt-get update
   apt-get upgrade
   apt-get dist-upgrade


It could be necessary to reboot your system in case you have a kernel upgrade

2.2.Networking
------------

* Only one NIC should have an internet access, the other is for most Openstack-related operations and configurations::

   #For Exposing OpenStack API over the internet
   auto eth1
   iface eth1 inet static
   address 192.168.1.251
   netmask 255.255.255.0
   gateway 192.168.1.1
   dns-nameservers 192.168.1.1

   #Not internet connected(used for OpenStack management)
   auto eth0
   iface eth0 inet static
   address 10.10.10.51
   netmask 255.255.255.0

Please Note that in our simple architecture the DNS-nameservers and the default gateway are the same!


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
 


2.5. Databases set up
-------------------

**Note:** Be patient: I have the habit to explicitly set rules for each ip address, even if the '%' should be sufficient :-)

* Setting up Databases::

   mysql -u root -p your_mysql_root_password
   #Keystone
   CREATE DATABASE keystone;
   GRANT ALL ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'openstacktest';
   GRANT ALL ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'openstacktest';
   GRANT ALL ON keystone.* TO 'keystone'@'10.10.10.51' IDENTIFIED BY 'openstacktest';
   GRANT ALL ON keystone.* TO 'keystone'@'192.168.1.251' IDENTIFIED BY 'openstacktest';
   FLUSH PRIVILEGES;
   quit;
   (test database access and show databases with user keystone)

   #Glance
   mysql -u root -p your_mysql_root_password
   CREATE DATABASE glance;
   GRANT ALL ON glance.* TO 'glance'@'%' IDENTIFIED BY 'openstacktest';
   GRANT ALL ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'openstacktest';
   GRANT ALL ON glance.* TO 'glance'@'10.10.10.51' IDENTIFIED BY 'openstacktest';
   GRANT ALL ON glance.* TO 'glance'@'192.168.1.251' IDENTIFIED BY 'openstacktest';
   FLUSH PRIVILEGES;
   quit;
   (test database access and show databases with user glance)

   #Neutron
   mysql -u root -p your_mysql_root_password
   CREATE DATABASE neutron;
   GRANT ALL ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'openstacktest';
   GRANT ALL ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'openstacktest';
   GRANT ALL ON neutron.* TO 'neutron'@'10.10.10.51' IDENTIFIED BY 'openstacktest';
   GRANT ALL ON neutron.* TO 'neutron'@'192.168.1.251' IDENTIFIED BY 'openstacktest';
   FLUSH PRIVILEGES;
   quit;
   (test database access and show databases with user neutron)

   #Nova
   mysql -u root -p your_mysql_root_password
   CREATE DATABASE nova;
   GRANT ALL ON nova.* TO 'nova'@'%' IDENTIFIED BY 'openstacktest';
   GRANT ALL ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'openstacktest';
   GRANT ALL ON nova.* TO 'nova'@'10.10.10.51' IDENTIFIED BY 'openstacktest';
   GRANT ALL ON nova.* TO 'nova'@'192.168.1.251' IDENTIFIED BY 'openstacktest';
   FLUSH PRIVILEGES;
   quit;
   (test database access and show databases with user nova)

   #Cinder
   mysql -u root -p your_mysql_root_password
   CREATE DATABASE cinder;
   GRANT ALL ON cinder.* TO 'cinder'@'%' IDENTIFIED BY 'openstacktest';
   GRANT ALL ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY 'openstacktest';
   GRANT ALL ON cinder.* TO 'cinder'@'10.10.10.51' IDENTIFIED BY 'openstacktest';
   GRANT ALL ON cinder.* TO 'cinder'@'192.168.1.251' IDENTIFIED BY 'openstacktest';
   FLUSH PRIVILEGES;
   quit;
   (test database access and show databases with user cinder)



2.6. Others
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


* Adapt the connection attribute in the /etc/keystone/keystone.conf to the new database::

   connection = mysql://keystone:openstacktest@10.10.10.51/keystone

* Restart the identity service then synchronize the database::

   service keystone restart
   keystone-manage db_sync

* Fill up the keystone database using the two scripts available in the `Scripts folder <https://github.com/mseknibilel/OpenStack-Grizzly-Install-Guide/tree/master/KeystoneScripts>`_ of this git repository::

   #Modify the HOST_IP and HOST_IP_EXT variables before executing the scripts
   
   wget https://raw.github.com/fornyx/OpenStack-Install-Guides/master/KeystoneScripts/keystone_basic.sh
   wget https://raw.github.com/fornyx/OpenStack-Install-Guides/master/KeystoneScripts/keystone_endpoints_basic.sh

   chmod +x keystone_basic.sh
   chmod +x keystone_endpoints_basic.sh

   ./keystone_basic.sh
   ./keystone_endpoints_basic.sh

* Create a simple credential file and load it so you won't be bothered later::

   nano/vi keystone_source

   #Paste the following:
   export OS_TENANT_NAME=admin
   export OS_USERNAME=admin
   export OS_PASSWORD=openstacktest
   export OS_AUTH_URL="http://192.168.1.251:5000/v2.0/"

   # Load it:
   source keystone_source

* To test Keystone, just use a simple CLI command::

   keystone user-list

4. Glance
=============

* We Move now to Glance installation::

   apt-get install -y glance

* Verify your glance services are running::

   service glance-api status
   service glance-registry status


* Update /etc/glance/glance-api-paste.ini with::

   [filter:authtoken]
   paste.filter_factory = keystoneclient.middleware.auth_token:filter_factory
   delay_auth_decision = true
   auth_host = 10.10.10.51
   auth_port = 35357
   auth_protocol = http
   admin_tenant_name = service
   admin_user = glance
   admin_password = openstacktest

* Update the /etc/glance/glance-registry-paste.ini with::

   [filter:authtoken]
   paste.filter_factory = keystoneclient.middleware.auth_token:filter_factory
   auth_host = 10.10.10.51
   auth_port = 35357
   auth_protocol = http
   admin_tenant_name = service
   admin_user = glance
   admin_password = openstacktest

* Update /etc/glance/glance-api.conf with::

   sql_connection = mysql://glance:openstacktest@10.10.10.51/glance

* And::

   [paste_deploy]
   flavor = keystone
   

* Restart the glance-api and glance-registry services::

   service glance-api restart; service glance-registry restart

* Synchronize the glance database::

   glance-manage db_sync

* Restart the services again to take into account the new modifications::

   service glance-registry restart; service glance-api restart

* To test Glance, upload the cirros cloud image and Ubuntu cloud image::

   glance image-create --name myFirstImage --is-public true --container-format bare --disk-format qcow2 --location https://launchpad.net/cirros/trunk/0.3.0/+download/cirros-0.3.0-x86_64-disk.img
   
   (mind you will be able to access VMs created with such image with the following credentials: user:cirros passwd: cubswin:))

   wget http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-amd64-disk1.img

   glance add name="Ubuntu 12.04 cloudimg amd64" is_public=true container_format=ovf disk_format=qcow2 < ./precise-server-cloudimg-amd64-disk1.img
   


* Now list the image to see what you have just uploaded::

   glance image-list
   

5. Neutron
=============

5.1. OpenVSwitch
------------------

* Install the openVSwitch::

   apt-get install -y openvswitch-controller openvswitch-switch openvswitch-datapath-dkms

* Restart openVSwitch::

   service openvswitch-switch restart

* Create the bridges::

   #br-int will be used for VM integration	
   ovs-vsctl add-br br-int

   #br-ex is used to make VMs to access the internet
   ovs-vsctl add-br br-ex

5.1.1. OpenVSwitch (Part2, modify network parameters)
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

* If you want to get internet connection back, you can assign the eth1's IP address to the br-ex in the /etc/network/interfaces file::

   auto br-ex
   iface br-ex inet static
   address 192.168.1.251
   netmask 255.255.255.0
   gateway 192.168.1.1
   dns-nameservers 192.168.1.1
   
* If you want IMMEDIATELY want your FULL networking features back I suggest::

   reboot
   source keystone_source (to get your environnment variables back)


* Note to VirtualBox users, you will likely be using host-only adapters for the private networking. You need to provide a route out of the host-only network to contact the outside world; egress is not supported by host-only adapters. This can be done by routing traffic from br-ex to an additional NAT'ed adapter that you can add. Run these commands (where NAT'ed adapter is eth2)::

   iptables --table nat --append POSTROUTING --out-interface eth2 -j MASQUERADE
   iptables --append FORWARD --in-interface br-ex -j ACCEPT



5.2. Neutron-*
------------------

* Install the Neutron components::

   apt-get install -y neutron-server neutron-plugin-openvswitch neutron-plugin-openvswitch-agent dnsmasq neutron-dhcp-agent neutron-l3-agent neutron-metadata-agent
   

* Verify all Neutron components are running::

   cd /etc/init.d/; for i in $( ls neutron-* ); do sudo service $i status; cd; done
   
* Edit /etc/neutron/api-paste.ini ::

   [filter:authtoken]
   paste.filter_factory = keystoneclient.middleware.auth_token:filter_factory
   auth_host = 10.10.10.51
   auth_port = 35357
   auth_protocol = http
   admin_tenant_name = service
   admin_user = neutron
   admin_password = openstacktest

* Edit the OVS plugin configuration file /etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini with::: 

   #Under the database section
   [DATABASE]
   sql_connection=mysql://neutron:openstacktest@10.10.10.51/neutron

   #Under the OVS section
   [OVS]
   tenant_network_type = gre
   enable_tunneling = True
   tunnel_id_ranges = 1:1000
   integration_bridge = br-int
   tunnel_bridge = br-tun
   local_ip = 10.10.10.51

   #Firewall driver for realizing neutron security group function
   [SECURITYGROUP]
   firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver

* Update /etc/neutron/metadata_agent.ini::

   # The Neutron user information for accessing the Neutron API.
   auth_url = http://10.10.10.51:35357/v2.0
   auth_region = RegionOne
   admin_tenant_name = service
   admin_user = neutron
   admin_password = openstacktest

   # IP address used by Nova metadata server
   nova_metadata_ip = 10.10.10.51
   

   # TCP Port used by Nova metadata server
   nova_metadata_port = 8775

   metadata_proxy_shared_secret = helloOpenStack

* Edit your /etc/neutron/neutron.conf::

   #RabbitMQ IP
   rabbit_host = 10.10.10.51

   [keystone_authtoken]
   auth_host = 10.10.100.51
   auth_port = 35357
   auth_protocol = http
   admin_tenant_name = service
   admin_user = neutron
   admin_password = openstacktest
   signing_dir = /var/lib/neutron/keystone-signing
   
   [DATABASE]
   connection = mysql://neutron:openstacktest@10.10.10.51/neutron


* Edit your /etc/neutron/l3_agent.ini::

   [DEFAULT]
   interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver
   use_namespaces = True
   external_network_bridge = br-ex
   signing_dir = /var/cache/neutron
   admin_tenant_name = service
   admin_user = neutron
   admin_password = openstacktest
   auth_url = http://10.10.10.51:35357/v2.0
   l3_agent_manager = neutron.agent.l3_agent.L3NATAgentWithStateReport
   root_helper = sudo neutron-rootwrap /etc/neutron/rootwrap.conf
   interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver


* Edit your /etc/neutron/dhcp_agent.ini::

   [DEFAULT]
   interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver
   dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
   use_namespaces = True
   signing_dir = /var/cache/neutron
   admin_tenant_name = service
   admin_user = neutron
   admin_password = openstacktest
   auth_url = http://10.10.10.51:35357/v2.0
   dhcp_agent_manager = neutron.agent.dhcp_agent.DhcpAgentWithStateReport
   root_helper = sudo neutron-rootwrap /etc/neutron/rootwrap.conf
   state_path = /var/lib/neutron



* Restart all neutron services::

   cd /etc/init.d/; for i in $( ls neutron-* ); do sudo service $i restart; cd /root/; done
   service dnsmasq restart
   
   and check status:
   cd /etc/init.d/; for i in $( ls neutron-* ); do sudo service $i status; cd /root/; done
   service dnsmasq status
   
   then check all neutron agents:
   neutron agent-list
   (hopefully you'll enjoy smiling faces :-) )


6. Nova
===========

6.1 KVM
------------------

* make sure that your hardware enables virtualization::

   apt-get install cpu-checker
   kvm-ok

* it could be necessary to do::

   sudo modprobe kvm_intel
   kvm-ok

* Finally you should get::

   INFO: /dev/kvm exists
   KVM acceleration can be used

   
* Let's go for KVM installation::

   apt-get install -y kvm libvirt-bin pm-utils



* Edit the cgroup_device_acl array in the /etc/libvirt/qemu.conf file to::

   cgroup_device_acl = [
   "/dev/null", "/dev/full", "/dev/zero",
   "/dev/random", "/dev/urandom",
   "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
   "/dev/rtc", "/dev/hpet","/dev/net/tun"
   ]


* Delete default virtual bridge ::

   virsh net-destroy default
   virsh net-undefine default

* Enable live migration by updating /etc/libvirt/libvirtd.conf file::

   listen_tls = 0
   listen_tcp = 1
   auth_tcp = "none"

* Edit libvirtd_opts variable in /etc/init/libvirt-bin.conf file::

   env libvirtd_opts="-d -l"

* Edit /etc/default/libvirt-bin file ::

   libvirtd_opts="-d -l"

* Restart the libvirt service and dbus to load the new values::

   service dbus restart && service libvirt-bin restart
   
   then check status:
   
   service dbus status && service libvirt-bin status
   

6.2 Nova-*
------------------

* Start by installing nova components::

   apt-get install -y nova-api nova-cert novnc nova-consoleauth nova-scheduler nova-novncproxy nova-doc nova-conductor nova-compute-kvm

* Check the status of all nova-services::

   cd /etc/init.d/; for i in $( ls nova-* ); do service $i status; cd; done


* Now modify authtoken section in the /etc/nova/api-paste.ini file to this::

   [filter:authtoken]
   paste.filter_factory = keystoneclient.middleware.auth_token:filter_factory
   auth_host = 10.10.10.51
   auth_port = 35357
   auth_protocol = http
   admin_tenant_name = service
   admin_user = nova
   admin_password = openstacktest
   signing_dirname = /tmp/keystone-signing-nova
   # Workaround for https://bugs.launchpad.net/nova/+bug/1154809
   auth_version = v2.0

* Modify the /etc/nova/nova.conf like this::

   [DEFAULT]
   logdir=/var/log/nova
   state_path=/var/lib/nova
   lock_path=/run/lock/nova
   verbose=True
   api_paste_config=/etc/nova/api-paste.ini
   compute_scheduler_driver=nova.scheduler.simple.SimpleScheduler
   rabbit_host=10.10.10.51
   nova_url=http://10.10.10.51:8774/v1.1/
   sql_connection=mysql://nova:openstacktest@10.10.10.51/nova
   root_helper=sudo nova-rootwrap /etc/nova/rootwrap.conf

   # Auth
   use_deprecated_auth=false
   auth_strategy=keystone

   # Imaging service
   glance_api_servers=10.10.10.51:9292
   image_service=nova.image.glance.GlanceImageService

   # Vnc configuration
   novnc_enabled=true
   novncproxy_base_url=http://192.168.1.251:6080/vnc_auto.html
   novncproxy_port=6080
   vncserver_proxyclient_address=10.10.10.51
   vncserver_listen=0.0.0.0

   # Network settings
   network_api_class=nova.network.neutronv2.api.API
   neutron_url=http://10.10.10.51:9696
   neutron_auth_strategy=keystone
   neutron_admin_tenant_name=service
   neutron_admin_username=neutron
   neutron_admin_password=openstacktest
   neutron_admin_auth_url=http://10.10.10.51:35357/v2.0
   libvirt_vif_driver=nova.virt.libvirt.vif.LibvirtHybridOVSBridgeDriver
   linuxnet_interface_driver=nova.network.linux_net.LinuxOVSInterfaceDriver
   #If you want Neutron + Nova Security groups
   #firewall_driver=nova.virt.firewall.NoopFirewallDriver
   #security_group_api=neutron
   #If you want Nova Security groups only, comment the two lines above and uncomment line -1-.
   #-1-firewall_driver=nova.virt.libvirt.firewall.IptablesFirewallDriver
   
   #Metadata
   service_neutron_metadata_proxy = True
   neutron_metadata_proxy_shared_secret = helloOpenStack
   metadata_host = 10.10.10.51
   metadata_listen = 127.0.0.1
   metadata_listen_port = 8775
   
   # Compute #
   compute_driver=libvirt.LibvirtDriver
   
   # Cinder #
   volume_api_class=nova.volume.cinder.API
   osapi_volume_listen_port=5900
   cinder_catalog_info=volume:cinder:internalURL



* Edit the /etc/nova/nova-compute.conf::

   [DEFAULT]
   libvirt_type=kvm
   libvirt_ovs_bridge=br-int
   libvirt_vif_type=ethernet
   libvirt_vif_driver=nova.virt.libvirt.vif.LibvirtHybridOVSBridgeDriver
   libvirt_use_virtio_for_bridges=True
    
* Restart nova-* services::

   cd /etc/init.d/; for i in $( ls nova-* ); do sudo service $i restart; cd /root/;done

   cd /etc/init.d/; for i in $( ls nova-* ); do sudo service $i status; cd /root/;done

   (mind nova cert is ok if it’s down: still the db has to be built up!)



* Synchronize your database::

   nova-manage db sync

* Restart nova-* services::

   cd /etc/init.d/; for i in $( ls nova-* ); do sudo service $i restart; cd /root/;done

   ...and check:
   
   cd /etc/init.d/; for i in $( ls nova-* ); do sudo service $i status; cd /root/;done
   

* Hopefully you should enjoy smiling faces on nova-* services to confirm your installation::

   nova-manage service list
   

7. Cinder
===========

* Install the required packages::

   apt-get install -y cinder-api cinder-scheduler cinder-volume iscsitarget open-iscsi iscsitarget-dkms

* Configure the iscsi services::

   sed -i 's/false/true/g' /etc/default/iscsitarget

* Start the services::
   
   service iscsitarget start
   service open-iscsi start


* Configure /etc/cinder/api-paste.ini like the following::

   [filter:authtoken]
   paste.filter_factory = keystoneclient.middleware.auth_token:filter_factory
   service_protocol = http
   service_host = 192.168.1.251
   service_port = 5000
   auth_host = 10.10.1.51
   auth_port = 35357
   auth_protocol = http
   admin_tenant_name = service
   admin_user = cinder
   admin_password = openstacktest


* Edit the /etc/cinder/cinder.conf to::

   [DEFAULT]
   rootwrap_config=/etc/cinder/rootwrap.conf
   sql_connection = mysql://cinder:openstacktest@10.10.10.51/cinder
   api_paste_config = /etc/cinder/api-paste.ini
   iscsi_helper=ietadm
   volume_name_template = volume-%s
   volume_group = cinder-volumes
   verbose = True
   auth_strategy = keystone
   #osapi_volume_listen_port=5900

* Then, synchronize your database::

   cinder-manage db sync

* Finally, don't forget to create a volumegroup and name it cinder-volumes::

   dd if=/dev/zero of=cinder-volumes bs=1 count=0 seek=2G
   losetup /dev/loop2 cinder-volumes
   fdisk /dev/loop2
   #Type in the followings:
   n
   p
   1
   ENTER
   ENTER
   t
   8e
   w

* Proceed to create the physical volume then the volume group::

   pvcreate /dev/loop2
   vgcreate cinder-volumes /dev/loop2

**Note:** Beware that this volume group gets lost after a system reboot. 

* Restart the cinder services::

   cd /etc/init.d/; for i in $( ls cinder-* ); do sudo service $i restart; cd /root/; done

* Verify if cinder services are running::

   cd /etc/init.d/; for i in $( ls cinder-* ); do sudo service $i status; cd /root/; done


8. Horizon
===========

* To install horizon, proceed like this ::

   apt-get -y install openstack-dashboard memcached

* If you don't like the OpenStack ubuntu theme, you can remove the package to disable it::

   dpkg --purge openstack-dashboard-ubuntu-theme 

* Reload Apache and memcached::

   service apache2 restart; service memcached restart

You can now access your OpenStack **192.168.1.251/horizon** with credentials **admin:openstacktest**.

9. Your first VM
================

To start your first VM, we first need to create a new tenant, user and internal network.

* Create a new tenant ::

   keystone tenant-create --name project_one

* Create a new user and assign the member role to it in the new tenant (keystone role-list to get the appropriate id)::

   keystone user-create --name=user_one --pass=user_one --tenant-id $put_id_of_project_one --email=user_one@domain.com
   keystone user-role-add --tenant-id $put_id_of_project_one  --user-id $put_id_of_user_one --role-id $put_id_of_member_role

* Create a new network for the tenant::

   neutron net-create --tenant-id $put_id_of_project_one net_proj_one 

* Create a new subnet inside the new tenant network::

   neutron subnet-create --tenant-id $put_id_of_project_one net_proj_one 50.50.1.0/24 --dns_nameservers list=true 192.168.1.1

* Create a router for the new tenant::

   neutron router-create --tenant-id $put_id_of_project_one router_proj_one

* Add the router to the running l3 agent (If it's not automatically added)::

   neutron agent-list (to get the l3 agent ID)
   neutron l3-agent-router-add $l3_agent_ID router_proj_one

* Add the router to the subnet::

   neutron router-interface-add $put_router_proj_one_id_here $put_subnet_id_here

* Restart all neutron services::

   cd /etc/init.d/; for i in $( ls neutron-* ); do sudo service $i restart; cd;done
   
   check services are on:
   
   cd /etc/init.d/; for i in $( ls neutron-* ); do sudo service $i status; cd;done
   
   ...and check agent looking for smiling faces :-)
   
   neutron agent-list


* Create an external network with the tenant id belonging to the admin tenant (keystone tenant-list to get the appropriate id)::

   neutron net-create --tenant-id $put_id_of_admin_tenant ext_net --router:external=True

* Create a subnet for floating IPs::
   
   neutron subnet-create --tenant-id $put_id_of_admin_tenant --allocation-pool start=192.168.1.52,end=192.168.1.76 --gateway 192.168.1.251 ext_net 192.168.1.0/24 --enable_dhcp=False
   
NOTE: Important: in case of mono-server installation the server host ip address MUST be the gateway!!!!, in our case it’s 192.168.1.251..in case of a multi-server installation with controller, Network Controller and compute nodes, the gateway would be the "normal" network gateway, in our case 192.168.1.1


* Set your router's gateway to the external network::

   neutron router-gateway-set $put_router_proj_one_id_here $put_id_of_ext_net_here



* Create a Source file with your own user and tenant credentials relative to your project one::

   nano creds_proj_one

   #Paste the following:
   export OS_TENANT_NAME=project_one
   export OS_USERNAME=user_one
   export OS_PASSWORD=user_one
   export OS_AUTH_URL="http://192.168.1.251:5000/v2.0/"

   source creds_proj_one

Now some few operations to clarify the minimum necessary operations about ssh

* Create a Keypair (if you haven't already done)::

   ssh-keygen -t rsa -C "youraccountname@youremaildomain.com"
   
   nova keypair-add --pub_key ~/.ssh/id_rsa.pub mykey
   
   list your keypairs to check:
   
   nova keypair-list
   
   (you should get something like:)
   
   +-------+-------------------------------------------------+
   | Name  | Fingerprint                                     |
   +-------+-------------------------------------------------+
   | mykey | 1a:91:f9:12:ed:f3:a0:f2:f6:6b:17:63:e1:6b:4f:d4 |
   +-------+-------------------------------------------------+

After ssh operations we get back to our business

* Add security rules to make your VMs pingable::

   nova --no-cache secgroup-add-rule default icmp -1 -1 0.0.0.0/0
   
   nova --no-cache secgroup-add-rule default tcp 22 22 0.0.0.0/0

* Allocating a floating ip to the project one tenant::

   neutron floatingip-create ext_net
   
* Start a Virtual Machine with the "holy" cirros image :-)::

   nova --no-cache boot --image $id_myFirstImage --flavor 1 my_first_vm


* Pick the id of the port corresponding to your VM::

   neutron port-list


* Associate the floating IP to your VM::

   neutron floatingip-associate $put_id_floating_ip $put_id_vm_port

9.1. Accessing VMs
-----------------

In this installation we did configure namespaces, this means that you cannot directly ping/ssh/access a VM DIRECTLY
Referring to our precedent operations in cap. "9", let's suppose that you created a VM with
IP address:
50.50.1.3
and that the associated floating IP is:
192.168.1.53

* you DO CAN ping/ssh 192.168.1.53, so::

   both:
   ping 192.168.1.53
   
   and
   ssh cirros@192.168.1.53
   
   should work fine!


But you CANNOT ping/ssh 50.50.1.3 DIRECTLY

* It is necessary to digit at prompt::
   
   ip netns
   
   you'll get some long codes, one of them will be the dhcp associated with your internal network, it should look like:
   qdhcp-6d9da13e-263b-4162-8d10-beed97497723
   (you can distinguish between each object just investigating on the Horizon web interfaces: look for network properties)
   
   you can use that namespace to access your created VM even without a floating IP with the following commands:
   
   ip netns exec qdhcp-6d9da13e-263b-4162-8d10-beed97497723 ping 50.50.1.3
   
   ip netns exec qdhcp-6d9da13e-263b-4162-8d10-beed97497723 ssh cirros@50.50.1.2
   

for more information we suggest the following link:
http://docs.openstack.org/grizzly/basic-install/apt/content/basic-install_operate.html
(paritularly: "Procedure 3.4. To SSH into the launched instance")


10. Adding a Compute Node
================

All this document do refer to a "demo" installation, optimization of services allocation on servers is out of the scope of this document.
Nevertheless we think that can be useful and appreciated to indicate the minimum operations that are necessary to add a compute node once you finished previous steps and you have a working ALL-IN-ONE installation.

This is the assumed IP plan for the second compute node:
:Node Role: Controller, Network Controller and Compute Node
:Nics: eth0 (10.10.10.52), eth1 (192.168.1.252)

.....of course you can follow this guide adding as many compute nodes you want...just change network parameters coherently...
...and always mind that an optimization of the services allocated on each node is out of the scope of THIS document

10.1. Preparing the Node
-----------------

* After you install Ubuntu 12.04 Server 64bits, Go in sudo mode and don't leave it until the end of this guide::

   sudo su

* Add Havana repositories::

   apt-get install ubuntu-cloud-keyring python-software-properties software-properties-common python-keyring
   echo deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-proposed/havana main >> /etc/apt/sources.list.d/havana.list

* Update your system::

   apt-get update
   apt-get upgrade
   apt-get dist-upgrade


It could be necessary to reboot your system in case you have a kernel upgrade

* Install ntp service::

   apt-get install -y ntp


* Configure the NTP server to follow the controller node::

   #Comment the ubuntu NTP servers
   sed -i 's/server 0.ubuntu.pool.ntp.org/#server 0.ubuntu.pool.ntp.org/g' /etc/ntp.conf
   sed -i 's/server 1.ubuntu.pool.ntp.org/#server 1.ubuntu.pool.ntp.org/g' /etc/ntp.conf
   sed -i 's/server 2.ubuntu.pool.ntp.org/#server 2.ubuntu.pool.ntp.org/g' /etc/ntp.conf
   sed -i 's/server 3.ubuntu.pool.ntp.org/#server 3.ubuntu.pool.ntp.org/g' /etc/ntp.conf

   #Set the compute node to follow up your conroller node
   sed -i 's/server ntp.ubuntu.com/server 10.10.10.51/g' /etc/ntp.conf

   service ntp restart


* Install ntp service::

   apt-get install -y vlan bridge-utils

* Enable IP_Forwarding::

   sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
   
   # To save you from rebooting NOW, perform the following
   sysctl net.ipv4.ip_forward=1


10.2. Networking
-----------------

* Setup Networking (in usual /etc/network/interfaces file)::

   # The primary network interface
   auto eth0
    iface eth0 inet static
    address 10.10.10.52
    netmask 255.255.255.0

   auto eth1
    iface eth1 inet static
    address 192.168.1.252
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 192.168.1.1


Attention: gateway to internet is essential to install all packets so we configured it on eth1 coherently with network (so far in this guide) BUT since we should have only ONE internet access for the cloud MIND to remove it at the end of the installation!

10.3. KVM
-----------------

* make sure that your hardware enables virtualization::

   apt-get install -y cpu-checker
   kvm-ok
   
* Attention: in case you get something like::

   INFO: /dev/kvm does not exist
   HINT:   sudo modprobe kvm_intel
   INFO: Your CPU supports KVM extensions
   KVM acceleration can be used

* Just digit the following::
   
   sudo modprobe kvm_intel
   kvm-ok
   
* Then when you finally get something like::
   INFO: /dev/kvm exists
   KVM acceleration can be used

   
   .....THEN JUST GO AHEAD AND LIVE IN PEACE :-)


(ATTENTION: I AM ACTUALLY WORKING ON THIS PARAGRAPH/CHAPTER :-))


11. Licensing
============

This OpenStack Havana Install Guide is licensed under a Creative Commons Attribution 3.0 Unported License.

.. image:: http://i.imgur.com/4XWrp.png
To view a copy of this license, visit [ http://creativecommons.org/licenses/by/3.0/deed.en_US ].

12. Contacts
===========

Marco Fornaro  : marco.fornaro@gmail.com

13. Credits
=================

This work has been based on:

TODO

14. To do
=======

Your suggestions are always welcomed.




