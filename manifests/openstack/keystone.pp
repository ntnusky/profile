# Installs and configures the keystone identity API.
class profile::openstack::keystone {
  $confhaproxy = hiera('profile::openstack::haproxy::configure::backend', true)

  require ::profile::baseconfig::firewall
  require ::profile::openstack::keystone::base
  contain ::profile::openstack::keystone::endpoint
  contain ::profile::openstack::keystone::firewall::server
  contain ::profile::openstack::keystone::keepalived
  contain ::profile::openstack::keystone::ldap
  require ::profile::openstack::repo

  if($confhaproxy) {
    contain ::profile::openstack::keystone::haproxy::backend::server
  }
}
