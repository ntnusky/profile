# Configures ceph to facilitate for cinder, and for cinder to use ceph for
# storage.
class profile::openstack::cinder::ceph {
  $ceph_key = hiera('profile::ceph::nova_key')

  ceph_config {
    'client.nova/key': value => $ceph_key;
  }

  ceph::key { 'client.cinder':
    secret  => $ceph_key,
    cap_mon => 'allow r',
    cap_osd =>
      'allow class-read object_prefix rbd_children, allow rwx pool=cinder',
    inject  => true,
  }
}
