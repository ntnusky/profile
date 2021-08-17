# Default firewall rules for haproxy
class profile::services::haproxy::firewall {
  ::profile::baseconfig::firewall::service::management { 'haproxy':
    port     => 9000,
    protocol => 'tcp',
  }
}
