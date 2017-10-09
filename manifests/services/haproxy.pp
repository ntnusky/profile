# Baseconfig for all haproxy servers

class profile::services::haproxy {

  require ::firewall

  $nic = hiera('profile::interfaces::management')
  $ip = $facts['networking']['interfaces'][$nic]['ip']

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
      "${ip}:9000"     => [],
      '127.0.0.1:9000' => [],
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
}
