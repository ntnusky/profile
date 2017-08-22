# Installs and configures horizon
class profile::openstack::horizon {
  $django_secret = hiera('profile::horizon::django_secret')
  $memcache_ip = hiera('profile::memcache::ip')
  $horizon_allowed_hosts = hiera('profile::horizon::allowed_hosts')
  $horizon_server_aliases = hiera('profile::horizon::server_aliases')
  $controller_api = hiera('controller::api::addresses')
  $server_name = hiera('profile::horizon::server_name')

  $horizon_ip = hiera('profile::api::horizon::public::ip')
  $keystone_ip = hiera('profile::api::keystone::public::ip')

  $ldap_name = hiera('profile::keystone::ldap_backend::name')

  contain ::profile::openstack::horizon::keepalived
  require ::profile::openstack::horizon::ssl
  require ::profile::openstack::repo

  include ::profile::services::apache::firewall

  class { '::horizon':
    allowed_hosts                => concat(['127.0.0.1', $::fqdn, $horizon_ip ],
      $controller_api, $horizon_allowed_hosts
    ),
    server_aliases               => concat(['127.0.0.1', $::fqdn, $horizon_ip ],
      $controller_api, $horizon_server_aliases
    ),
    secret_key                   => $django_secret,
    cache_server_ip              => $memcache_ip,
    listen_ssl                   => true,
    servername                   => $server_name,
    horizon_cert                 => '/etc/ssl/certs/horizon.crt',
    horizon_key                  => '/etc/ssl/private/horizon.key',
    horizon_ca                   => '/etc/ssl/certs/CA.crt',
    keystone_multidomain_support => true,
    keystone_default_domain      => $ldap_name,
    keystone_url                 => "http://${keystone_ip}:5000",
    session_timeout              => 7200,
    neutron_options              => {
      enable_firewall => true,
    },
  }
}
