# Configures the firewall to accept vncproxy connections
class profile::openstack::nova::firewall::vncproxy {
  $managementnet = hiera('profile::networks::management::ipv4::prefix')

  require ::profile::baseconfig::firewall

  firewall { '500 accept Nova VNC proxy':
    source => $managementnet,
    proto  => 'tcp',
    dport  => '6080',
    action => 'accept',
  }
}
