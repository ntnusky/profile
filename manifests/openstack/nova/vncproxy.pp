# Installs the nova vnc proxy
class profile::openstack::nova::vncproxy {
  include ::profile::openstack::nova::firewall::vncproxy
  include ::profile::openstack::nova::haproxy::backend::vnc
  require ::profile::openstack::repo

  $cert = hiera('profile::haproxy::services::apicert', false)
  $host = hiera('profile::horizon::server_name')
  $port = hiera('profile::vncproxy::port', 6080)

  if($cert) {
    $protocol = 'https'
  } else {
    $protocol = 'http'
  }

  class { '::nova::vncproxy::common':
    vncproxy_host     => $host,
    vncproxy_protocol => $protocol,
    vncproxy_port     => $port,
    before            => Class['::nova::vncproxy'],
  }

  class { '::nova::vncproxy':
    enabled => true,
  }
}
