# Provides the base-configuration of bird for IPv6
class profile::bird::config::ipv6 {
  require ::profile::bird::install
  include ::profile::bird::service::ipv6

  # Determine the management IP. Either select the first found on the management
  # interface, or use the IP set in hiera, if there are an IP in hiera.
  $management_if = lookup('profile::interfaces::management', String)
  $management_auto4 = $facts['networking']['interfaces'][$management_if]['ip']
  $management_ipv4 = lookup("profile::interfaces::${management_if}::address", {
    'value_type'    => String,
    'default_value' => $management_auto4,
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
