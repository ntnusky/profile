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
  $zookeeper_whitelist_commands = lookup('profile::zookeeper::whitelist_commands', {
    'value_type'    => Array[String],
    'default_value' => ['srvr', 'ruok', 'stat', 'dirs', 'mntr', 'isro']
  })
  $zabbixservers = lookup('profile::zabbix::agent::servers', {
    'default_value' => [],
    'value_type'    => Array[Stdlib::IP::Address::Nosubnet],
  })
  # If the array contains at least one element:
  if($zabbixservers =~ Array[Stdlib::IP::Address::Nosubnet, 1]) {
    include ::profile::zabbix::agent::zookeeper
  }

  ::profile::firewall::infra::all { 'zookeeper-clients':
    port => 2181,
  }
  ::profile::firewall::custom { 'zookeeper-servers':
    port     => [ 2888, 3888 ],
    prefixes => values($zookeeper_servers),
  }

  class { '::zookeeper':
    id            => $zookeeper_serverid,
    servers       => $zookeeper_servers,
    whitelist_4lw => $zookeeper_whitelist_commands,
  }
}
