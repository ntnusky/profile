# Installs and configures bird for IPv6 if there is defined an IPv6 address in
# hiera under the key 'profile::anycast::ipv4' 
class profile::bird::ipv4 {
  $anycastv4 = lookup('profile::anycast::ipv4', {
    'default_value' => undef,
    'value_type'    => Optional[Stdlib::IP::Address::V4::Nosubnet],
  })
  $bgpmetric = lookup('profile::bird::anycast::med', {
    'default_value' => 500,
    'value_type'    => Integer,
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
    $statics = lookup('profile::bird::ipv4::static', {
      'value_type'    => Variant[
        Boolean,
        Hash[Stdlib::IP::Address::V4::CIDR, Hash],
      ],
      'default_value' => false
    })

    if($neighbour) {
      $neighbours = $_neighbours <<  $neighbour
    } else {
      $neighbours = $_neighbours
    }

    $neighbours.each | $peer | {
      ::profile::bird::config::bgp { "v4anycast-${peer}":
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
      med        => $bgpmetric,
      prefixes   => [ "${anycastv4}/32" ],
    }

    if($statics) {
      ::profile::bird::config::static { 'v4anycast':
        configfile => '/etc/bird/bird.conf',
        prefixes   => $statics,
      }
    }
  }
}
