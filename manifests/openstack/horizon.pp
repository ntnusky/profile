# Installs and configures the horizon dashboard on an openstack controller node
# in the SkyHiGh architecture
class profile::openstack::horizon {
  $django_secret = hiera('profile::horizon::django_secret')
  $memcache_ip = hiera('profile::memcache::ip')
  $horizon_allowed_hosts = hiera('profile::horizon::allowed_hosts')
  $horizon_server_aliases = hiera('profile::horizon::server_aliases')
  $controller_api = hiera('controller::api::addresses')
  $server_name = hiera('profile::horizon::server_name')

  $horizon_ip = hiera('profile::api::horizon::public::ip')
  $vrrp_password     = hiera('profile::keepalived::vrrp_password')
  $vrid = hiera('profile::api::horizon::vrrp::id')
  $vrpri = hiera('profile::api::horizon::vrrp::priority')

  $if_public = hiera('profile::interfaces::public')

  $ssl_key = hiera('profile::horizon::ssl_key')
  $ssl_cert = hiera('profile::horizon::ssl_cert')
  $ssl_ca = hiera('profile::horizon::ssl_ca')

  anchor { 'profile::openstack::horizon::begin' :
    require => [
      Anchor['profile::mysqlcluster::end'],
      Anchor['profile::ceph::monitor::end'],
    ],
    before  => Class['::horizon'],
  }

  file { '/etc/ssl/private/horizon.key':
    ensure  => file,
    content => $ssl_key,
  } ->
  file { '/etc/ssl/certs/horizon.crt':
    ensure  => file,
    content => $ssl_cert,
  } ->
  file { '/etc/ssl/certs/CA.crt':
    ensure  => file,
    content => $ssl_ca,
  } ->
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
#   keystone_default_domain      => $ldap_name,
  }

  keepalived::vrrp::script { 'check_horizon':
    script => '/usr/bin/killall -0 apache2',
  }

  keepalived::vrrp::instance { 'public-horizon':
    interface         => $if_public,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${horizon_ip}/32",
    ],
    track_script      => 'check_horizon',
  }
}
