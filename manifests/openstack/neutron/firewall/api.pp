# Configures the firewall to pass incoming traffic to the neutron API.
class profile::openstack::neutron::firewall::api {
  require ::profile::baseconfig::firewall

  $managemnet_net = hiera('profile::networks::management::ipv4::prefix')

  firewall { '500 accept incoming admin neutron tcp':
    source => $managemnet_net,
    proto  => 'tcp',
    dport  => '9696',
    action => 'accept',
  }
}
