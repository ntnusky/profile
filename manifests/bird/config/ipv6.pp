# Provides the base-configuration of bird for IPv6
class profile::bird::config::ipv6 {
  require ::profile::bird::install
  include ::profile::bird::service::ipv6

  # TODO: Stop looking for the management-IP in hiera, and simply just take it 
  # from SL.
  if($::sl2) {
    $default = $::sl2['server']['primary_interface']['name']
  } else {
    $default = undef
  }

  $management_if = lookup('profile::interfaces::management', {
    'default_value' => $default, 
    'value_type'    => String,
  })
  $management_ipv4 = lookup("profile::baseconfig::network::interfaces.${management_if}.ipv4.address", {
    'value_type'    => String,
    'default_value' => $facts['networking']['interfaces'][$management_if]['ip'], 
  })

  # If a router-id is set in hiera; use it. Otherwise, use the IP from the
  # management interface.
  $router_id = lookup('profile::bird::router::id', {
    'value_type'    => String,
    'default_value' => $management_ipv4,
  })

  concat { '/etc/bird/bird6.conf':
    ensure         => present,
    ensure_newline => true,
    notify         => Service['bird6'],
    warn           => true,
  }

  concat::fragment { 'Bird6 RouterID':
    target  => '/etc/bird/bird6.conf',
    content => "router id ${router_id};",
    order   => '01',
  }

  concat::fragment { 'Bird6 Listen BGP':
    target  => '/etc/bird/bird6.conf',
    content => 'listen bgp v6only;',
    order   => '02',
  }

  concat::fragment { 'Bird6 General':
    target  => '/etc/bird/bird6.conf',
    content => epp('profile/bird/general.epp'),
    order   => '05',
  }
}
