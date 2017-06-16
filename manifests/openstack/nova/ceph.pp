# This class configures ceph for nova.
class profile::openstack::nova::ceph {
  require ::profile::ceph::client

  $nova_key = hiera('profile::ceph::nova_key')

  exec { '/usr/bin/ceph osd pool create volumes 512' :
    unless => '/usr/bin/ceph osd pool get volumes size',
  }

  ceph_config {
    'client.nova/key': value => $nova_key;
  }

  $top = 'allow class-read object_prefix rbd_children'
  $volumes = 'allow rwx pool=volumes'
  $images = 'allow rwx pool=images'
  ceph::key { 'client.nova':
    secret  => $nova_key,
    cap_mon => 'allow r',
    cap_osd => "${top},${volumes}, ${images}",
    inject  => true,
  }
}
