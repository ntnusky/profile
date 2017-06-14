# Configures ceph to facilitate for cinder, and for cinder to use ceph for
# storage.
class profile::openstack::cinder::ceph {
  $ceph_key = hiera('profile::ceph::nova_key')
  $ceph_uuid = hiera('profile::ceph::nova_uuid')

  require ::profile::openstack::repo

  ceph_config {
    'client.nova/key': value => $ceph_key;
  }

  class { 'cinder::volume::rbd':
    rbd_pool        => 'volumes',
    rbd_user        => 'nova',
    rbd_secret_uuid => $ceph_uuid,
  }

  ceph::key { 'client.cinder':
    secret  => $ceph_key,
    cap_mon => 'allow r',
    cap_osd =>
      'allow class-read object_prefix rbd_children, allow rwx pool=cinder',
    inject  => true,
  }
}
