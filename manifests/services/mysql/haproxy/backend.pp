# Configures the haproxy backend for this mysql cluster member
class profile::services::mysql::haproxy::backend {
  $if = hiera('profile::interfaces::management')
  $autoip = $::facts['networking']['interfaces'][$if]['ip']
  $ip = hiera("profile::interfaces::${if}::address", $autoip)

  profile::services::haproxy::tools::register { "Mysql-${::fqdn}":
    servername  => $::hostname,
    backendname => 'bk_mysqlcluster',
  }

  @@haproxy::balancermember { "mysql-${::fqdn}":
    listening_service => 'bk_mysqlcluster',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '3306',
    options           => 'backup check',
  }
}
