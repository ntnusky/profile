# Haproxy backend for shiftleader
class profile::services::shiftleader::haproxy::backend {
  if($::sl2) {
    $default = $::sl2['server']['primary_interface']['name']
  } else {
    $default = undef
  }
  $if = lookup('profile::interfaces::management', {
    'default_value' => $default, 
    'value_type'    => String,
  })

  ::profile::services::haproxy::backend { 'Shiftleader2':
    backend   => 'bk_shiftleader2',
    interface => $if,
    options   => [ 'check inter 5s', ],
    port      => '80',
  }
}
