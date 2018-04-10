# Installs and configures the keystone identity API.
class profile::openstack::keystone {
  $confhaproxy = hiera('profile::openstack::haproxy::configure::backend', true)
  $keystoneip = hiera('profile::api::keystone::admin::ip', false)

  require ::profile::baseconfig::firewall
  require ::profile::openstack::keystone::base
  contain ::profile::openstack::keystone::endpoint
  contain ::profile::openstack::keystone::firewall::server
  contain ::profile::openstack::keystone::ldap
  require ::profile::openstack::repo

  # If this server should be placed behind haproxy, export a haproxy
  # configuration snippet.
  if($confhaproxy) {
    contain ::profile::openstack::keystone::haproxy::backend::server
  }
  
  # Only configure keepalived if we actually have a shared IP for keystone. We
  # use this in the old controller-infrastructure. New infrastructures should be
  # based on haproxy instead.
  if($keystoneip) {
    contain ::profile::openstack::keystone::keepalived
  }
}
