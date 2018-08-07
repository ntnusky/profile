# Configures the firewall for puppetmasters. 
class profile::services::puppet::db::firewall {
  require ::firewall

  $managementv4 = hiera('profile::networks::management::ipv4::prefix', false)
  $managementv6 = hiera('profile::networks::management::ipv6::prefix', false)

  if($managementv4) {
    firewall { '051 Accept incoming puppetdb':
      proto  => 'tcp',
      dport  => 8081,
      action => 'accept',
      source => $managementv4,
    }
  }

  if($managementv6) {
    firewall { '051 ipv6 Accept incoming puppetdb':
      proto    => 'tcp',
      dport    => 8081,
      action   => 'accept',
      provider => 'ip6tables',
      source   => $managementv6,
    }
  }
}
