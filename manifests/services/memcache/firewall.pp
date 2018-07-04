# Firewall rules for memcached
class profile::services::memcache::firewall {
  require ::profile::baseconfig::firewall

  $management_if = hiera('profile::interfaces::management')
  $memcached_port = hiera('profile::memcache::port', '11211')

  $sourcev4 = hiera('profile::networks::management::ipv4::prefix', false)
  $sourcev6 = hiera('profile::networks::management::ipv6::prefix', false)

  if ( $sourcev4 ) {
    $destv4 = $::facts['networking']['interfaces'][$management_if]['ip']

    firewall { '500 accept incoming memcached tcp':
      source      => $sourcev4,
      destination => $destv4,
      proto       => 'tcp',
      dport       => $memcached_port,
      action      => 'accept',
    }

    firewall { '500 accept incoming memcached udp':
      source      => $sourcev4,
      destination => $destv4,
      proto       => 'udp',
      dport       => $memcached_port,
      action      => 'accept',
    }
  }

  if ( ! $sourcev6 ) {
    $destv6 = $::facts['networking']['interfaces'][$management_if]['ip6']

    firewall { '500 accept ipv6 incoming memcached tcp':
      source      => $sourcev6,
      destination => $destv6,
      proto       => 'tcp',
      dport       => $memcached_port,
      action      => 'accept',
      provider    => 'ip6tables',
    }

    firewall { '500 accept ipv6 incoming memcached udp':
      source      => $sourcev6,
      destination => $destv6,
      proto       => 'udp',
      dport       => $memcached_port,
      action      => 'accept',
      provider    => 'ip6tables',
    }
  }
}
