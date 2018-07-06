#Configures the firewall for the mysql loadbalancers
class profile::services::mysql::firewall::balancer {
  require ::firewall

  $managementv4 = hiera('profile::networks::management::ipv4::prefix', false)
  $managementv6 = hiera('profile::networks::management::ipv6::prefix', false)

  if($managementv4) {
    firewall { '071 Accept incoming MySQL requests':
      source => $managementv4,
      proto  => 'tcp',
      dport  => 3306,
      action => 'accept',
    }
  }

  if($managementv6) {
    firewall { '071 ipv6 Accept incoming MySQL requests':
      source   => $managementv6,
      proto    => 'tcp',
      dport    => 3306,
      action   => 'accept',
      provider => 'ip6tables', 
    }
  }
}
