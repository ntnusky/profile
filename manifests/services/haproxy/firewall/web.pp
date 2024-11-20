# Open the firewall for incoming web-requests to the haproxy-loadbalancer.
class profile::services::haproxy::firewall::web {
  $prefixes = lookup('profile::haproxy::web::clients', {
    'default_value' => ['0.0.0.0/0', '::/0'],
    'value_type'    => Array[Stdlib::IP::Address],
  })

  ::profile::firewall::custom { 'web':
    port     => [80,443],
    prefixes => $prefixes,
  }
}
