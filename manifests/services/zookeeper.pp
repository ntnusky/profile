# Install and configure Zookeeper cluster

class profile::services::zookeeper {
  # - Open firewall
  # - Install zookeeper
  $zookeeper_servers = lookup('profile::zookeeper::servers', { 
    'value_type' => Hash[Integer, Stdlib::IP::Address::Nosubnet],
  })

  ::profile::firewall::infra::all { 'zookeeper-clients':
    port => 2181,
  }
  ::profile::firewall::custom { 'zookeeper-servers':
    port     => [ 2888, 3888 ],
    prefixes => values($zookeeper_servers),
  }
}
