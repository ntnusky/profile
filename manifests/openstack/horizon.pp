class profile::openstack::horizon {
  $django_secret = hiera("profile::horizon::django_secret")
  $memcache_ip = hiera("profile::memcache::ip")
  $horizon_allowed_hosts = hiera("profile::horizon::allowed_hosts")
  $horizon_server_aliases = hiera("profile::horizon::server_aliases")
  $controller_api = hiera("controller::api::addresses")
  $apache_key = hiera("profile::horizon::apache_key")
  $server_name = hiera("profile::horizon::server_name")

  $horizon_ip = hiera("profile::api::horizon::public::ip")
  $vrrp_password 	= hiera("profile::keepalived::vrrp_password")
  $vrid = hiera("profile::api::horizon::vrrp::id")
  $vrpri = hiera("profile::api::horizon::vrrp::priority")

  $if_public = hiera("profile::interfaces::public")
  

  anchor { "profile::openstack::horizon::begin" : 
    require => [ Anchor["profile::mysqlcluster::end"], 
                 Anchor["profile::ceph::monitor::end"], ],
    before => Class["::horizon"],
  }

  file { '/etc/ssl/private/horizon.key':
    ensure  => file,
    content => "${apache_key}",
  } ->
  file { '/etc/ssl/certs/horizon.crt':
    ensure => file,
    source => 'puppet:///modules/profile/keys/certs/horizon.crt',
  } ->
  class { '::horizon':
    allowed_hosts   => concat(['127.0.0.1', $::fqdn, $horizon_ip ], $controller_api, $horizon_allowed_hosts),
    server_aliases  => concat(['127.0.0.1', $::fqdn, $horizon_ip ], $controller_api, $horizon_server_aliases),
    secret_key      => $django_secret,
    cache_server_ip => $memcache_ip,
    listen_ssl      => true,
    servername      => $server_name,
    horizon_cert    => '/etc/ssl/certs/horizon.crt',
    horizon_key     => '/etc/ssl/private/horizon.key',
    horizon_ca      => '/etc/ssl/certs/horizon.crt',
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
