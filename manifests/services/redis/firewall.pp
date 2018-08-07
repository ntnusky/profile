# Configure firewall for redis servers
class profile::services::redis::firewall {
  require ::firewall

  $managementv4 = hiera('profile::networks::management::ipv4::prefix', false)
  $managementv6 = hiera('profile::networks::management::ipv6::prefix', false)

  if($managementv4) {
    firewall { '050 accept redis-server':
      proto  => 'tcp',
      dport  => 6379,
      action => 'accept',
      source => $managementv4,
    }
  }

  if($managementv6) {
    firewall { '050 ipv6 accept redis-server':
      proto    => 'tcp',
      dport    => 6379,
      action   => 'accept',
      provider => 'ip6tables',
      source   => $managementv6,
    }
  }
}
