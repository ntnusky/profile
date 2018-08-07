# Configures the firewall for puppetmasters. 
class profile::services::puppet::server::firewall {
  require ::firewall

  $managementv4 = hiera('profile::networks::management::ipv4::prefix', false)
  $managementv6 = hiera('profile::networks::management::ipv6::prefix', false)

  if($managementv4) {
    firewall { '050 Accept incoming puppet':
      proto  => 'tcp',
      dport  => 8140,
      action => 'accept',
      source => $managementv4,
    }
  }

  if($managementv6) {
    firewall { '050 ipv6 Accept incoming puppet':
      proto    => 'tcp',
      dport    => 8140,
      action   => 'accept',
      provider => 'ip6tables',
      source   => $managementv6,
    }
  }
}
