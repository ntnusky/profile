# Firewall rules for memcached
class profile::services::memcache::firewall {
  $memcached_port = lookup('profile::memcache::port', {
    'default_value' => 11211,
    'value_type'    => Integer,
  })

  ::profile::baseconfig::firewall::service::infra { 'TCP Memcache':
    protocol => 'tcp',
    port     => $memcached_port,
  }
  ::profile::baseconfig::firewall::service::infra { 'UDP Memcache':
    protocol => 'udp',
    port     => $memcached_port,
  }
}
