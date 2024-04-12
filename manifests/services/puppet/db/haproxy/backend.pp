# Configures the haproxy backend for this puppetdb server
class profile::services::puppet::db::haproxy::backend {
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

  ::profile::services::haproxy::backend { 'PuppetDB':
    backend   => 'bk_puppetdb',
    interface => $if,
    options   => 'check',
    port      => '8081',
  }
}
