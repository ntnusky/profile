# Opens the firewall for the keystone port from any source
class profile::openstack::keepalive::firewall::haproxy::services {
  require ::firewall

  firewall { '100 Keystone API - Public':
    proto  => 'tcp',
    dport  => 5000,
    action => 'accept',
  }
}
