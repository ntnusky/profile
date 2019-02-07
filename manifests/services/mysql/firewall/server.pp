#Configures the firewall for the mysql servers
class profile::services::mysql::firewall::server {
  require ::profile::baseconfig::firewall

  $infrav4 = lookup('profile::networking::infrastructure::ipv4::prefixes', {
    'value_type' => Array[Stdlib::IP::Address::V4::CIDR],
    'merge'      => 'unique',
  })
  $infrav6 = lookup('profile::networking::infrastructure::ipv6::prefixes', {
    'value_type'    => Array[Stdlib::IP::Address::V6::CIDR],
    'merge'         => 'unique',
    'default_value' => [],
  })

  $infrav4.each | $net | {
    firewall { "070 Accept incoming MySQL requests from ${net}":
      proto  => 'tcp',
      dport  => 3306,
      action => 'accept',
      source => $net,
    }

    firewall { "071 Accept incoming MySQL galera from ${net}":
      proto  => 'tcp',
      dport  => [4567, 4568, 4444, 9000],
      action => 'accept',
      source => $net,
    }

    firewall { "072 Accept incoming MySQL galera from ${net}":
      proto  => 'udp',
      dport  => 4567,
      action => 'accept',
      source => $net,
    }
  }

  $infrav6.each | $net | {
    firewall { "070 Accept incoming MySQL requests from ${net}":
      proto    => 'tcp',
      dport    => 3306,
      action   => 'accept',
      source   => $net,
      provider => 'ip6tables',
    }

    firewall { "071 Accept incoming MySQL galera from ${net}":
      proto    => 'tcp',
      dport    => [4567, 4568, 4444, 9000],
      action   => 'accept',
      source   => $net,
      provider => 'ip6tables',
    }

    firewall { "072 Accept incoming MySQL galera from ${net}":
      proto    => 'udp',
      dport    => 4567,
      action   => 'accept',
      source   => $net,
      provider => 'ip6tables',
    }
  }
}
