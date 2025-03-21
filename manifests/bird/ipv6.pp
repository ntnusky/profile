# Installs and configures bird for IPv6 if there is defined an IPv6 address in
# hiera under the key 'profile::anycast::ipv6' 
class profile::bird::ipv6 {
  $anycastv6 = lookup('profile::anycast::ipv6', {
    'default_value' => undef,
    'value_type'    => Optional[Stdlib::IP::Address::V6::Nosubnet],
  })
  $bgpmetric = lookup('profile::bird::anycast::med', {
    'default_value' => 500,
    'value_type'    => Integer,
  })

  if($anycastv6) {
    include ::profile::bird::config::ipv6

    $local_as = lookup('profile::bird::anycast::ipv6::bgp::as::local', {
      'value_type'    => Integer,
    })
    $remote_as = lookup('profile::bird::anycast::ipv6::bgp::as::remote', {
      'value_type'    => Integer,
    })
    $multihop = lookup('profile::bird::anycast::ipv6::bgp::multihop', {
      'value_type'    => Integer,
      'default_value' => 1,
    })
    $neighbour = lookup('profile::bird::anycast::ipv6::bgp::peer', {
      'value_type'    => Variant[String, Boolean],
      'default_value' => false,
    })
    $_neighbours = lookup('profile::bird::anycast::ipv6::bgp::peers', {
      'value_type'    => Array[String],
      'default_value' => [],
    })
    $statics = lookup('profile::bird::ipv6::static', {
      'value_type'    => Variant[
        Boolean,
        Hash[Stdlib::IP::Address::V6::CIDR, Hash],
      ],
      'default_value' => false,
    })

    if($neighbour) {
      $neighbours = $_neighbours << $neighbour
    } else {
      $neighbours = $_neighbours
    }

    $neighbours.each | $peer | {
      ::profile::bird::config::bgp { "v6anycast-${peer}":
        configfile  => '/etc/bird/bird6.conf',
        filtername  => 'v6anycast',
        aslocal     => $local_as,
        asremote    => $remote_as,
        multihop    => $multihop,
        neighbourip => $peer,
      }
    }

    ::profile::bird::config::filter { 'v6anycast':
      configfile => '/etc/bird/bird6.conf',
      med        => $bgpmetric,
      prefixes   => [ "${anycastv6}/128" ],
    }

    if($statics) {
      ::profile::bird::config::static { 'v6anycast':
        configfile => '/etc/bird/bird6.conf',
        prefixes   => $statics,
      }
    }
  }
}
