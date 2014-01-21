#!/bin/sh

mysql -u root -p << EOF
CREATE DATABASE keystone;
GRANT ALL ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'openstacktest';
GRANT ALL ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'openstacktest';
GRANT ALL ON keystone.* TO 'keystone'@'10.10.10.51' IDENTIFIED BY 'openstacktest';
GRANT ALL ON keystone.* TO 'keystone'@'192.168.1.251' IDENTIFIED BY 'openstacktest';
FLUSH PRIVILEGES;

CREATE DATABASE glance;
GRANT ALL ON glance.* TO 'glance'@'%' IDENTIFIED BY 'openstacktest';
GRANT ALL ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'openstacktest';
GRANT ALL ON glance.* TO 'glance'@'10.10.10.51' IDENTIFIED BY 'openstacktest';
GRANT ALL ON glance.* TO 'glance'@'192.168.1.251' IDENTIFIED BY 'openstacktest';
FLUSH PRIVILEGES;

CREATE DATABASE neutron;
GRANT ALL ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'openstacktest';
GRANT ALL ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'openstacktest';
GRANT ALL ON neutron.* TO 'neutron'@'10.10.10.51' IDENTIFIED BY 'openstacktest';
GRANT ALL ON neutron.* TO 'neutron'@'192.168.1.251' IDENTIFIED BY 'openstacktest';
FLUSH PRIVILEGES;

CREATE DATABASE nova;
GRANT ALL ON nova.* TO 'nova'@'%' IDENTIFIED BY 'openstacktest';
GRANT ALL ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'openstacktest';
GRANT ALL ON nova.* TO 'nova'@'10.10.10.51' IDENTIFIED BY 'openstacktest';
GRANT ALL ON nova.* TO 'nova'@'192.168.1.251' IDENTIFIED BY 'openstacktest';
FLUSH PRIVILEGES;

CREATE DATABASE cinder;
GRANT ALL ON cinder.* TO 'cinder'@'%' IDENTIFIED BY 'openstacktest';
GRANT ALL ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY 'openstacktest';
GRANT ALL ON cinder.* TO 'cinder'@'10.10.10.51' IDENTIFIED BY 'openstacktest';
GRANT ALL ON cinder.* TO 'cinder'@'192.168.1.251' IDENTIFIED BY 'openstacktest';
FLUSH PRIVILEGES;
EOF
