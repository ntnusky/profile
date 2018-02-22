# Configures the firewall to accept incoming traffic to the cinder API. 
class profile::openstack::cinder::firewall::server {
  $managementnet = hiera('profile::networks::management::ipv4::prefix')

  require ::profile::baseconfig::firewall

  firewall { '500 accept Cinder API':
    source => $managementnet,
    proto  => 'tcp',
    dport  => '8776',
    action => 'accept',
  }
}
