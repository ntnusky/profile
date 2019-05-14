# Define balancer members for munin haproxy backend
class profile::monitoring::munin::haproxy::balancermember {
  $management_if = lookup('profile::interfaces::management', String)
  $mip = $facts['networking']['interfaces'][$management_if]['ip']
  $management_ip = lookup("profile::baseconfig::network::interfaces.${management_if}.ipv4.address", {
    'value_type'    => Stdlib::IP::Address::V4,
    'default_value' => $mip
  })

  profile::services::haproxy::tools::register { "Munin-${::fqdn}":
    servername  => $::hostname,
    backendname => 'bk_munin',
  }

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
