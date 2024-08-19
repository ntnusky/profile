# Configures the haproxy in frontend for the rest-api in the ceph cluster
class profile::ceph::haproxy::frontend {
  include ::profile::ceph::firewall::rest
  include ::profile::services::haproxy::certs::manageapi

  ::profile::services::haproxy::frontend { 'Ceph-REST':
    certfile => '/etc/ssl/private/haproxy.managementapi.pem',
    mode     => 'http',
    profile  => 'management',
    port     => 8003,
  }
}
