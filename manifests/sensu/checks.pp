# Sensu check definitions
class profile::sensu::checks {

  contain ::profile::sensu::checks::base
  contain ::profile::sensu::checks::ceph
  contain ::profile::sensu::checks::certs
  contain ::profile::sensu::checks::dell
  contain ::profile::sensu::checks::haproxy
  contain ::profile::sensu::checks::lvm
  contain ::profile::sensu::checks::memcached
  contain ::profile::sensu::checks::mysql
  contain ::profile::sensu::checks::physical
  contain ::profile::sensu::checks::rabbitmq
  contain ::profile::sensu::checks::redis
  contain ::profile::sensu::checks::web

  contain ::profile::sensu::checks::openstack::adminapi
  contain ::profile::sensu::checks::openstack::floatingip
  contain ::profile::sensu::checks::openstack::publicapi

}
