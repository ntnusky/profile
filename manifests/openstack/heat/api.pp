# Installs the heat API
class profile::openstack::heat::api {
  $confhaproxy = hiera('profile::openstack::haproxy::configure::backend', true)
  $heat_admin_ip = hiera('profile::api::heat::admin::ip', false)

  require ::profile::openstack::heat::base
  require ::profile::openstack::heat::firewall::api
  require ::profile::openstack::repo

  if($heat_admin_ip) {
    contain ::profile::openstack::heat::keepalived
  }

  if($confhaproxy) {
    contain ::profile::openstack::heat::haproxy::backend::server
  }

  class { '::heat::api' : }
  class { '::heat::api_cfn' : }
}
