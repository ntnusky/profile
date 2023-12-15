# Configures the haproxy backend for this puppetmaster 
class profile::services::puppet::server::haproxy::backend {
  $if = lookup('profile::interfaces::management', {
    'default_value' => $::sl2['server']['primary_interface']['name'],
    'value_type'    => String,
  })

  ::profile::services::haproxy::backend { 'Puppetserver':
    backend   => 'bk_puppetserver',
    interface => $if,
    options   => 'check',
    port      => '8140',
  }
}
