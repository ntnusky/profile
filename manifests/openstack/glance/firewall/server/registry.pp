# Configures the firewall to accept incoming traffic to the glance registry API. 
class profile::openstack::glance::firewall::server::registry {
  $managementnet = hiera('profile::networks::management::ipv4::prefix')

  require ::profile::baseconfig::firewall

  firewall { '500 accept Glance Registry':
    source => $managementnet,
    proto  => 'tcp',
    dport  => '9191',
    action => 'accept',
  }
}
