# Installs the nova vnc proxy
class profile::openstack::nova::vncproxy {
  include ::nova::deps
  include ::profile::openstack::nova::firewall::vncproxy
  require ::profile::openstack::repo

  $cert = hiera('profile::haproxy::services::apicert', false)
  $host = hiera('profile::horizon::server_name')
  $port = hiera('profile::vncproxy::port', 6080)

  $confhaproxy = hiera('profile::openstack::haproxy::configure::backend', true)

  if($confhaproxy) {
    include ::profile::openstack::nova::haproxy::backend::vnc
  }

  if($cert) {
    $protocol = 'https'
  } else {
    $protocol = 'http'
  }

  class { '::nova::vncproxy::common':
    vncproxy_host     => $host,
    vncproxy_protocol => $protocol,
    vncproxy_port     => $port,
  }

  nova_config {
    'vnc/novncproxy_host': value => '0.0.0.0';
    'vnc/novncproxy_port': value => $port;
  }

  nova::generic_service { 'vncproxy':
    enabled        => true,
    manage_service => true,
    package_name   => 'nova-novncproxy',
    service_name   => 'nova-novncproxy',
    ensure_package => present,
  }
}
