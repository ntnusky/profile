# Haproxy backend for shiftleader
class profile::services::dashboard::haproxy::backend {
  $management_if = lookup('profile::interfaces::management', String)
  $mip = $facts['networking']['interfaces'][$management_if]['ip']
  $management_ip = lookup("profile::baseconfig::network::interfaces.${management_if}.ipv4.address", {
    'value_type'    => Stdlib::IP::Address::V4,
    'default_value' => $mip,
  })

  $register_loadbalancer = lookup('profile::haproxy::register', {
    'value_type'    => Boolean,
    'default_value' => True,
  })

  if($register_loadbalancer) {
    profile::services::haproxy::tools::register { "Shiftleader-${::fqdn}":
      servername  => $::hostname,
      backendname => 'bk_shiftleader',
    }
  
    @@haproxy::balancermember { "Shiftleader-${::fqdn}":
      listening_service => 'bk_shiftleader',
      ports             => '80',
      ipaddresses       => $management_ip,
      server_names      => $::hostname,
      options           => [
        'check inter 5s',
      ],
    }
  }
}
