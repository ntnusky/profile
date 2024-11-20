# Firewall rules for memcached
class profile::services::memcache::firewall {
  $memcached_port = lookup('profile::memcache::port', {
    'default_value' => 11211,
    'value_type'    => Integer,
  })

  ::profile::firewall::infra::region { 'Memcached TCP':
    port               => $memcached_port,
    transport_protocol => 'tcp',
  }
  ::profile::firewall::infra::region { 'Memcached UDP':
    port               => $memcached_port,
    transport_protocol => 'udp',
  }
}
