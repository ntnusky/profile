#Configures the firewall for the galera servers
class profile::services::mysql::firewall::galera {
  $common = lookup('profile::mysqlcluster::interregional', {
    'default_value' => false,
    'value_type'    => Boolean,
  })

  if($common) {
    ::profile::firewall::infra::all { 'MYSQL TCP Replication':
      port               => [4567, 4568, 4444, 9000],
      transport_protocol => 'tcp',
    }
    ::profile::firewall::infra::all { 'MYSQL UDP Replication':
      port               => 4567,
      transport_protocol => 'udp',
    }
  } else {
    ::profile::firewall::infra::region { 'MYSQL TCP Replication':
      port               => [4567, 4568, 4444, 9000],
      transport_protocol => 'tcp',
    }
    ::profile::firewall::infra::region { 'MYSQL UDP Replication':
      port               => 4567,
      transport_protocol => 'udp',
    }
  }
}
