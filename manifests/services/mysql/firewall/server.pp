#Configures the firewall for the mysql servers
class profile::services::mysql::firewall::server {
  ::profile::baseconfig::firewall::service::infra { 'MYSQL':
    protocol => 'tcp',
    port     => 3306,
  }
  ::profile::baseconfig::firewall::service::infra { 'MYSQL TCP Replication':
    protocol => 'tcp',
    port     => [4567, 4568, 4444, 9000],
  }
  ::profile::baseconfig::firewall::service::infra { 'MYSQL UDP Replication':
    protocol => 'udp',
    port     => 4567,
  }
}
