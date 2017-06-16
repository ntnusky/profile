# Installs the cinder scheduler
class profile::openstack::cinder::scheduler {
  require ::profile::openstack::repo
  require ::profile::openstack::cinder::base

  class { '::cinder::scheduler':
    enabled          => true,
  }

}
