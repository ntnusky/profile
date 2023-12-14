# Provides the base-configuration of bird for IPv4
class profile::bird::config::ipv4 {
  require ::profile::bird::install
  include ::profile::bird::service::ipv4

  # TODO: Stop looking for the management-IP in hiera, and simply just take it 
  # from SL.
  $management_if = lookup('profile::interfaces::management', {
    'default_value' => $::sl2['server']['primary_interface']['name'],
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

  concat { '/etc/bird/bird.conf':
    ensure         => present,
    ensure_newline => true,
    notify         => Service['bird'],
    warn           => true,
  }

  concat::fragment { 'Bird4 RouterID':
    target  => '/etc/bird/bird.conf',
    content => "router id ${router_id};",
    order   => '01'
  }

  concat::fragment { 'Bird4 General':
    target  => '/etc/bird/bird.conf',
    content => epp('profile/bird/general.epp'),
    order   => '05'
  }
}
