# Configures the haproxy backend for this puppetmaster 
class profile::services::puppet::server::haproxy::backend {
  # TODO: Stop looking for the management-IP in hiera, and simply just take it
  # from SL.
  if($::sl2) {
    $default = $::sl2['server']['primary_interface']['name']
  } else {
    $default = undef
  }
  $if = lookup('profile::interfaces::management', {
    'default_value' => $default, 
    'value_type'    => String,
  })

  ::profile::services::haproxy::backend { 'Puppetserver':
    backend   => 'bk_puppetserver',
    interface => $if,
    options   => 'check',
    port      => '8140',
  }
}
