# Installs and configures bird for IPv6 if there is defined an IPv6 address in
# hiera under the key 'profile::bird::anycast::ipv6::address' 
class profile::bird::ipv4 {
  $anycastv4 = lookup('profile::bird::anycast::ipv4::address', {
    'value_type'    => Variant[String, Boolean],
    'default_value' => false,
  })

  if($anycastv4) {
    include ::profile::bird::config::ipv4

    $local_as = lookup('profile::bird::anycast::ipv4::bgp::as::local', {
      'value_type'    => Integer,
    })
    $remote_as = lookup('profile::bird::anycast::ipv4::bgp::as::remote', {
      'value_type'    => Integer,
    })
    $multihop = lookup('profile::bird::anycast::ipv4::bgp::multihop', {
      'value_type'    => Integer,
      'default_value' => 1,
    })
    $neighbour = lookup('profile::bird::anycast::ipv4::bgp::peer', {
      'value_type'    => Variant[String, Boolean],
      'default_value' => false,
    })
    $_neighbours = lookup('profile::bird::anycast::ipv4::bgp::peers', {
      'value_type'    => Array[String],
      'default_value' => [],
    })

    if($neighbour) {
      $neighbours = $_neighbours <<  $neighbour
    } else {
      $neighbours = $_neighbours
    }

    $neighbours.each | $peer | {
      ::profile::bird::config::bgp { 'v4anycast':
        configfile  => '/etc/bird/bird.conf',
        filtername  => 'v4anycast',
        aslocal     => $local_as,
        asremote    => $remote_as,
        multihop    => $multihop,
        neighbourip => $peer,
      }
    }

    ::profile::bird::config::filter { 'v4anycast':
      configfile => '/etc/bird/bird.conf',
      prefixes   => [ "${anycastv4}/32" ],
    }
  }
}
