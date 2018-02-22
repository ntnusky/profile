# Firewall rules for memcached
class profile::services::memcache::firewall {
  require ::profile::baseconfig::firewall

  $management_if = hiera('profile::interfaces::management')
  $sourcev4 = hiera('profile::networks::management::ipv4::prefix')
  $sourcev4_extra = hiera('profile::networks::management::ipv4::prefix::extra', 
      false)
  $sourcev6 = hiera('profile::networks::management::ipv6::prefix')
  $memcached_port = '11211'
  $use_keepalived = hiera('profile::memcache::keepalived', false)

  if ( $use_keepalived ) {
    $destv4 = hiera('profile::memcache::ip')
  } else {
    $destv4 = $::facts['networking']['interfaces'][$management_if]['ip']
  }

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

  if($sourcev4_extra) {
    firewall { '500 accept incoming memcached tcp':
      source      => $sourcev4_extra,
      destination => $destv4,
      proto       => 'tcp',
      dport       => $memcached_port,
      action      => 'accept',
    }

    firewall { '500 accept incoming memcached udp':
      source      => $sourcev4_extra,
      destination => $destv4,
      proto       => 'udp',
      dport       => $memcached_port,
      action      => 'accept',
    }
  }

  if ( ! $use_keepalived ) {
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
