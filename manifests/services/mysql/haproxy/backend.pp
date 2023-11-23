# Configures the haproxy backend for this mysql cluster member
class profile::services::mysql::haproxy::backend {
  # TODO: Remove the hiera-lookup and just juse the sl2-data
  $if = lookup('profile::interfaces::management', {
    'default_value' => $::sl2['server']['primary_interface']['name'],
    'value_type'    => String,
  })

  ::profile::services::haproxy::backend { 'MySQL':
    backend   => 'bk_mysqlcluster',
    interface => $if,
    options   => 'backup check',
    port      => 3306,
  }
}
