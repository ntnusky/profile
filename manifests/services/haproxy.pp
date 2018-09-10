# Baseconfig for all haproxy servers

class profile::services::haproxy {

  require ::firewall

  $nic = hiera('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$nic]['ip']
  $installsensu = hiera('profile::sensu::install', true)
  $sslciphers = "\
ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:\
ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:\
ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:\
ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:\
ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256"
  $ssloptions = 'no-sslv3 no-tlsv10 no-tlsv11 no-tls-tickets'

  class { '::haproxy':
    merge_options  => true,
    global_options => {
      'log'                        => [
        '/dev/log local0',
        '/dev/log local1 notice',
      ],
      'maxconn'                    => '8000',
      'ssl-default-bind-ciphers'   => $sslciphers,
      'ssl-default-bind-options'   => $ssloptions,
      'ssl-default-server-ciphers' => $sslciphers,
      'ssl-default-server-options' => $ssloptions,
      'stats'                      => 'socket /var/lib/haproxy/stats mode 600 level admin',
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

  $ipv4_management_nets = hiera_array('profile::networking::management::ipv4::prefixes', false)
  $ipv6_management_nets = hiera_array('profile::networking::management::ipv6::prefixes', false)

  if($ipv4_management_nets) {
    $ipv4_management_nets.each |$net| {
      firewall { "060 accept haproxy stats from ${net}":
        proto  => 'tcp',
        dport  => 9000,
        source => $net,
        action => 'accept',
      }
    }
  } else {
    firewall { '060 accept haproxy stats':
      proto  => 'tcp',
      dport  => 9000,
      action => 'accept',
    }
  }

  if($ipv6_management_nets) {
    $ipv6_management_nets.each |$net| {
      firewall { "061 ipv6 accept incoming haproxy stats from ${net}":
        proto    => 'tcp',
        dport    => 9000,
        source   => $net,
        action   => 'accept',
        provider => 'ip6tables',
      }
    }
  } else {
    firewall { '060 ipv6 accept haproxy stats':
      proto    => 'tcp',
      dport    => 9000,
      action   => 'accept',
      provider => 'ip6tables',
    }
  }

  $installmunin = hiera('profile::munin::install', true)
  if($installmunin) {
    include ::profile::monitoring::munin::plugin::haproxy
  }
  if ($installsensu) {
    include ::profile::sensu::plugin::haproxy
    sensu::subscription { 'haproxy-servers': }
  }
}
