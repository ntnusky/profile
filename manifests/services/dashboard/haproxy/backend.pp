# Haproxy backend for shiftleader
class profile::services::dashboard::haproxy::backend {
  $management_if = hiera('profile::interfaces::management')
  $mip = $facts['networking']['interfaces'][$management_if]['ip']
  $management_ip = hiera("profile::interfaces::${management_if}::address", $mip)

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
      'cookie',
    ],
  }
}
