# Configures ceph to facilitate for cinder, and for cinder to use ceph for
# storage.
class profile::openstack::cinder::volume {
  $ceph_uuid = hiera('profile::ceph::nova_uuid')

  require ::profile::openstack::repo
  require ::profile::openstack::cinder::base
  require ::profile::openstack::cinder::ceph

  class { '::cinder::volume': }
  class { '::cinder::volume::rbd':
    rbd_pool        => 'volumes',
    rbd_user        => 'nova',
    rbd_secret_uuid => $ceph_uuid,
  }
}
