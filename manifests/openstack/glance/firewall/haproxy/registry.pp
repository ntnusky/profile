# Configures the firewall to accept incoming traffic to the glance registry API. 
class profile::openstack::glance::firewall::haproxy::registry {
  require ::firewall
  require ::profile::baseconfig::firewall

  $infra4_net1 = hiera('profile::networks::management::ipv4::prefix')
  $infra4_net2 = hiera('profile::networks::management::ipv4::prefix::extra', [])
  $infra4_nets = concat([], $infra4_net1, $infra4_net2)

  $infra6_net = hiera('profile::networks::management::ipv6::prefix', false)

  $infra4_nets.each | $net | {
    firewall { "500 accept Glance registry API - ${net}":
      proto  => 'tcp',
      dport  => '9191',
      source => $net,
      action => 'accept',
    }
  }

  if($infra6_net) {
    firewall { '500 accept Glance registry API for IPv6':
      proto    => 'tcp',
      dport    => '9191',
      action   => 'accept',
      source   => $infra6_net,
      provider => 'ip6tables',
    }
  }
}
