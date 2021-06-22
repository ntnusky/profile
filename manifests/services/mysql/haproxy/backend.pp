# Configures the haproxy backend for this mysql cluster member
class profile::services::mysql::haproxy::backend {
  $if = lookup('profile::interfaces::management', String)

  ::profile::services::haproxy::backend { 'MySQL':
    backend   => 'bk_mysqlcluster',
    interface => $if,
    options   => 'backup check',
    port      => '3306',
  }
}
