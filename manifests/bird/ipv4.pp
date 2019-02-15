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
    $neighbour = lookup('profile::bird::anycast::ipv4::bgp::peer', {
      'value_type'    => String,
    })

    ::profile::bird::config::bgp { 'v4anycast':
      configfile  => '/etc/bird/bird.conf',
      filtername  => 'v4anycast',
      aslocal     => $local_as,
      asremote    => $remote_as,
      neighbourip => $neighbour,
    }

    ::profile::bird::config::filter { 'v4anycast':
      configfile => '/etc/bird/bird.conf',
      prefixes   => [ "${anycastv4}/32" ],
    }
  }
}
