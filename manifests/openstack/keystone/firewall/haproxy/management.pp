# Opens the firewall for the keystone port from any source
class profile::openstack::keystone::firewall::haproxy::management {
  require ::firewall
  require ::profile::baseconfig::firewall

  $infra4_net1 = hiera('profile::networks::management::ipv4::prefix')
  $infra4_net2 = hiera('profile::networks::management::ipv4::prefix::extra', [])
  $mgmt4_nets = hiera_array('profile::networking::management::ipv4::prefixes')
  $infra4_nets = concat([], $infra4_net1, $infra4_net2)

  $infra6_net = hiera('profile::networks::management::ipv6::prefix', false)
  $mgmt6_nets = hiera_array('profile::networking::management::ipv6::prefixes', [])

  $mgmt4_nets.each | $net | {
    firewall { "100 Keystone API - Admin from ${net}":
      proto  => 'tcp',
      dport  => 35357,
      action => 'accept',
      source => $net,
    }
  }

  $infra4_nets.each | $net | {
    firewall { "100 Keystone API - Internal - ${net}":
      proto  => 'tcp',
      dport  => 5000,
      action => 'accept',
      source => $net,
    }
  }

  if($infra6_net) {
    firewall { '100 Keystone API v6 - Internal':
      proto    => 'tcp',
      dport    => 5000,
      action   => 'accept',
      source   => $infra6_net,
      provider => 'ip6tables',
    }
  }

  $mgmt6_nets.each | $net | {
    firewall { "100 Keystone API - Admin from ${net}":
      proto    => 'tcp',
      dport    => 35357,
      action   => 'accept',
      source   => $net,
      provider => 'ip6tables',
    }
  }

}
