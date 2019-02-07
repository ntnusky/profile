# Configure firewall for rabbitmq servers
class profile::services::rabbitmq::firewall {
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
    firewall { "500 accept incoming rabbitmq from ${net}":
      source => $net,
      proto  => 'tcp',
      dport  => 5672,
      action => 'accept',
    }
    firewall { "502 accept incoming rabbitmqcluster from ${net}":
      source => $net,
      proto  => 'tcp',
      dport  => [4369, 25672],
      action => 'accept',
    }
  }

  $infrav6.each | $net | {
    firewall { "500 accept incoming rabbitmq from ${net}":
      source   => $net,
      proto    => 'tcp',
      dport    => 5672,
      action   => 'accept',
      provider => 'ip6tables',
    }
    firewall { "502 accept incoming rabbitmqcluster from ${net}":
      source   => $net,
      proto    => 'tcp',
      dport    => [4369, 25672],
      action   => 'accept',
      provider => 'ip6tables',
    }
  }
}
