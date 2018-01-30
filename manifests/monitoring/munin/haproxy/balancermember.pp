# Define balancer members for munin haproxy backend
class profile::monitoring::munin::haproxy::balancermember {
  $management_if = hiera('profile::networking::interfaces::management')
  $management_ip = $::facts['networking']['interfaces'][$management_if]['ip']

  @@haproxy::balancermember { "munin-${::fqdn}":
    listening_service => 'bk_munin',
    ports             => '80',
    ipaddresses       => $management_ip,
    server_names      => $::hostname,
    options           => [
      'check inter 5s',
    ],
  }
}
