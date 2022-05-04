# Configures the haproxy in frontend for the mysql cluster
class profile::services::mysql::haproxy::frontend {
  include ::profile::services::mysql::firewall::balancer

  ::profile::services::haproxy::frontend { 'mysqlcluster':
    profile => 'management',
    port    => 3306,
    ftoptions => {
      'timeout client' => '90m',
    },
    bkoptions => {
      'timeout server' => '90m',
    },
  }
}
