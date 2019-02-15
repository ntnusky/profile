# Installs and configures bird for IPv6 if there is defined an IPv6 address in
# hiera under the key 'profile::bird::anycast::ipv6::address' 
class profile::bird::ipv6 {
  $anycastv6 = lookup('profile::bird::anycast::ipv6::address', {
    'value_type'    => Variant[String, Boolean],
    'default_value' => false,
  })

  if($anycastv6) {
    include ::profile::bird::config::ipv6

    $local_as = lookup('profile::bird::anycast::ipv6::bgp::as::local', {
      'value_type'    => Integer,
    })
    $remote_as = lookup('profile::bird::anycast::ipv6::bgp::as::remote', {
      'value_type'    => Integer,
    })
    $neighbour = lookup('profile::bird::anycast::ipv6::bgp::peer', {
      'value_type'    => String,
    })

    ::profile::bird::config::bgp { 'v6anycast':
      configfile  => '/etc/bird/bird6.conf',
      filtername  => 'v6anycast',
      aslocal     => $local_as,
      asremote    => $remote_as,
      neighbourip => $neighbour,
    }

    ::profile::bird::config::filter { 'v6anycast':
      configfile => '/etc/bird/bird6.conf',
      prefixes   => [ "${anycastv6}/128" ],
    }
  }
}
