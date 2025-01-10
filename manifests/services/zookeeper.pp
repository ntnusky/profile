# Install and configure Zookeeper cluster

class profile::services::zookeeper {
  # - Open firewall
  # - Install zookeeper
  $zookeeper_servers = lookup('profile::zookeeper::servers', { 
    'value_type' => Hash[String, Stdlib::IP::Address::Nosubnet],
  })
  $zookeeper_serverid = lookup('profile::zookeeper::server::id', { 
    'value_type' => String,
  })

  # Zabbix monitoring of Zookeeper
  include ::profile::zabbix::agent::zookeeper

  ::profile::firewall::infra::all { 'zookeeper-clients':
    port => 2181,
  }
  ::profile::firewall::custom { 'zookeeper-servers':
    port     => [ 2888, 3888 ],
    prefixes => values($zookeeper_servers),
  }

  class { '::zookeeper':
    id      => $zookeeper_serverid,
    servers => $zookeeper_servers,
  }
}
