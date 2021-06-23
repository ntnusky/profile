# Configures the haproxy backend for this puppetmaster 
class profile::services::puppet::server::haproxy::backend {
  $if = lookup('profile::interfaces::management', String)

  ::profile::services::haproxy::backend { 'Puppetserver':
    backend   => 'bk_puppetserver',
    interface => $if,
    options   => 'check',
    port      => 8140,
  }
}
