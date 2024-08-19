# Configures the haproxy in frontend for the rest-api in the ceph cluster
class profile::ceph::haproxy::frontend {
  include ::profile::services::haproxy::certs
  include ::profile::ceph::firewall::rest

  $certfile = lookup("profile::haproxy::${profile}::webcert::certfile", {
    'default_value' => '/etc/ssl/private/haproxy.pem',
    'value_type'    => String,
  })

  ::profile::services::haproxy::frontend { 'Ceph-REST':
    certfile => $certfile,
    profile  => 'management',
    port     => 8003,
  }
}
