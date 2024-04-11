# Define balancer members for munin haproxy backend
class profile::monitoring::munin::haproxy::balancermember {
  if($sl2) {
    $default = $::sl2['server']['primary_interface']['name']
  } else {
    $default = undef
  }

  $management_if = lookup('profile::interfaces::management', {
    'default_value' => $default, 
    'value_type'    => String,
  })

  ::profile::services::haproxy::backend { 'Munin':
    backend   => 'bk_munin',
    interface => $management_if,
    options   => 'check inter 5s',
    port      => '80',
  }
}
