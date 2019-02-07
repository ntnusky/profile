# Firewall rules for memcached
class profile::services::memcache::firewall {
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

  $memcached_port = lookup('profile::memcache::port', {
    'default_value' => 11211,
    'value_type'    => Integer,
  })

  $infrav4.each | $net | {
    firewall { "500 accept incoming memcached tcp from ${net}":
      source => $net,
      proto  => 'tcp',
      dport  => $memcached_port,
      action => 'accept',
    }

    firewall { "500 accept incoming memcached udp from ${net}":
      source => $net,
      proto  => 'udp',
      dport  => $memcached_port,
      action => 'accept',
    }
  }

  $infrav6.each | $net | {
    firewall { "500 accept incoming memcached tcp from ${net}":
      source   => $net,
      proto    => 'tcp',
      dport    => $memcached_port,
      action   => 'accept',
      provider => 'ip6tables',
    }

    firewall { "500 accept incoming memcached udp from ${net}":
      source   => $net,
      proto    => 'udp',
      dport    => $memcached_port,
      action   => 'accept',
      provider => 'ip6tables',
    }
  }
}
