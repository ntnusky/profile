# Installing SkyHiGh

This document covers all the steps required to install the full openstack cloud
solution as it is in HiGs SkyHiGh. The SkyHiGh currently implements the
following openstack components in a redundant manner:

 - [x] Keystone
 - [x] Neutron
 - [x] Nova
 - [x] Glance
 - [x] Cinder
 - [ ] Heat

## SkyHiGh structure

The structure of skyhigh is better described in another document, but as a quick
summary, it consists of three kinds of nodes:

 - Controllers:
   - 3 or more needed for redundant operation.
   - Responsible for "administrative" tasks like scheduling, resource 
     allocation, databases, networking. The lot.
 - Storage:
   - Need at least as many as you want to replicate your ceph data. For 3
     replicas in ceph, more than 3 is needed. They should contain several disks
	 and prefferably an SSD for journalling.
   - Responsible for the data storage.
 - Compute
   - As many as you like. Need more than 1 for live migration etc.
   - Is responsible for running the virtual machines.

## SkyHiGh installation instructions

When installing skyhigh, the controllers needs to be installed partly first, as
they provide a lot of base services. They cant however fully install first,
because they are dependant on the storage nodes to come up. The installation is 
therefore divided into four steps:

 - Install base controller services.
 - Install storage nodes.
 - Install controller nodes.
 - Install compute nodes.

It is generally a good idea to install the `role::base` on all machines first, to
be able to log in and verify network settings, harddrive naming and similar 
before the installation of the openstack services.

### Install base controller services

The controller role is divided into 4 steps:
 - `role::controller::step1`
 - `role::controller::step2`
 - `role::controller::step3`
 - `role::controller`

Step one installs a range of base services, and should be ran on all controllers
first. Then step two should be assigned, and puppet ran at the same time on
all controllers, as the mysql cluster needs all controllers to appear at the 
same time.

For some reason, at the installation in June, the mysql galera cluster did not
start properly, and needed a little help with the command: `service mysql start 
--wsrep-new-cluster`. This was not needed in the lab in K202 in April, so it is 
difficult to say what failed. It should be fixed in the future by someone... :)

When mysql is up and running, ceph monitors is next. The `role::controller::step3`
installs the ceph monitors, and this is very dependent that all controllers
do it at the same time to work, so a synchronized puppet run is smart. When
ceph monitors are installed, a "ceph -s" would give you the current status.

At this point, the base services is available on the controllers, and we should
get the storage up and running before installing all the openstack services.

### Install storage nodes.

Storage nodes are simple to install. It is two quick steps:
 - Make sure that all the disks are without partition tables.
   - "for disk in sdb sdc sdd sde sdf sdg sdh; do echo $disk; gdisk -l /dev/$disk | egrep '(MBR|GPT)' | grep -v fdisk | grep -v Creating; done" 
     would tell you if there is a partition table on any of the disks 
	 /dev/sd[bcdefgh].
   - "for disk in sdb sdc sdd sde sdf sdg sdh; do echo $disk; sgdisk -Z /dev/$disk; done" 
     would delete the partition table on the same disks. This is destructive, so
	 do not run on live disks.
 - Install the `role::storage`, and observe that the OSDs appears on the 
   controllers using "ceph -s".

### Finalize the controller installation

When the storage nodes are installed, and a "ceph health" returns OK, you are 
ready to install the openstack services on the controllers, and fill them with
initial data:

 - Install `role::controller` to all controllers.
 - On one of the controller, add some initial data:
   - [Create initial networks](http://docs.openstack.org/juno/install-guide/install/apt/content/neutron-initial-networks.html)
   - [Upload images](http://docs.openstack.org/juno/install-guide/install/apt/content/glance-verify.html)

### Install compute nodes

The installation of compute is simply installing `role::compute` at the machine.
