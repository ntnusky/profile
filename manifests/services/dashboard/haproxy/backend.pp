# Haproxy backend for shiftleader
class profile::services::dashboard::haproxy::backend {
  $management_if = hiera('profile::interfaces::management')
  $management_ip = $::facts['networking']['interfaces'][$management_if]['ip']

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
