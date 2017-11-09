# Baseconfig for all haproxy servers

class profile::services::haproxy {

  require ::firewall

  $nic = hiera('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$nic]['ip']
  $ipv6_management_nets = hiera_array('profile::networking::management::ipv6::prefixes')
  $installsensu = hiera('profile::sensu::install', true)

  class { '::haproxy':
    merge_options  => true,
    global_options => {
      'log'     => [
        '/dev/log local0',
        '/dev/log local1 notice',
      ],
      'maxconn' => '8000',
    },
  }

  haproxy::listen { 'stats':
    bind    => {
      '0.0.0.0:9000' => [],
      '::0:9000'     => [],
    },
    options => {
      'mode'  => 'http',
      'stats' => [
        'hide-version',
        'refresh 30s',
        'show-node',
        'uri /',
      ],
    },
  }

  firewall { '060 accept haproxy stats':
    proto  => 'tcp',
    dport  => 9000,
    action => 'accept',
  }
  $ipv6_management_nets.each |$net| {
    firewall { "061 ipv6 accept incoming haproxy stats from ${net}":
      proto    => 'tcp',
      dport    => 9000,
      source   => $net,
      action   => 'accept',
      provider => 'ip6tables',
    }
  }

  $installMunin = hiera('profile::munin::install', true)
  if($installMunin) {
    include ::profile::monitoring::munin::plugin::haproxy
  }
  if ($installsensu) {
    include ::profile::sensu::plugin::haproxy
  }
}
