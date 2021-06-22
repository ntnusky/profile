# Configures the haproxy backend for this puppetdb server
class profile::services::puppet::db::haproxy::backend {
  $if = lookup('profile::interfaces::management', String)

  ::profile::services::haproxy::backend { 'PuppetDB':
    backend   => 'bk_puppetdb',
    interface => $if,
    options   => 'check',
    port      => 8081,
  }
}
