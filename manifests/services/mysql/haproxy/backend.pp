# Configures the haproxy backend for this mysql cluster member
class profile::services::mysql::haproxy::backend {
  $if = hiera('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  @@haproxy::balancermember { "mysql-${::fqdn}":
    listening_service => 'bk_mysqlcluster',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '3306',
    options           => 'backup check',
  }
}
