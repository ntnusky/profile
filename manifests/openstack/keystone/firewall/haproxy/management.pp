# Opens the firewall for the keystone port from any source
class profile::openstack::keystone::firewall::haproxy::management {
  require ::firewall

  $infra_net1 = hiera('profile::networks::management::ipv4::prefix')
  $infra_net2 = hiera('profile::networks::management::ipv4::prefix::extra', [])
  $mgmt_nets = hiera_array('profile::networking::management::ipv4::prefixes')
  $infra_nets = concat([], $infra_net1, $infra_net2)

  $mgmt_nets.each | $net | {
    firewall { "100 Keystone API - Admin from ${net}":
      proto  => 'tcp',
      dport  => 35357,
      action => 'accept',
      source => $net,
    }
  }

  $mgmt_nets.each | $net | {
    firewall { "100 Keystone API - Internal - ${net}":
      proto  => 'tcp',
      dport  => 5000,
      action => 'accept',
      source => $net,
    }
  }
}
