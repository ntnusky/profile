# Exports a server-definition to be collected by the haproxy backends.
class profile::openstack::nova::haproxy::backend::metadata {
  $if = hiera('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  @@haproxy::balancermember { "nova-metadata-${::fqdn}":
    listening_service => 'bk_nova_metadata',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8775',
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
