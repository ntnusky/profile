# Configures the firewall for the keystone server
#  - We basicly only allow our management-network to use keystone, as the rest
#    of the traffic will enter trough the loadbalancers.
class profile::openstack::keystone::firewall::server {
  require ::profile::baseconfig::firewall

  $management_net = hiera('profile::networks::management::ipv4::prefix')

  firewall { '500 accept incoming admin keystone tcp':
    source => $management_net,
    proto  => 'tcp',
    dport  => [ '5000', '35357' ],
    action => 'accept',
  }
}
