# Baseconfig for all haproxy servers

class profile::services::haproxy {
  $sslciphers = "\
ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:\
ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:\
ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:\
ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:\
ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256"
  $ssloptions = 'no-sslv3 no-tlsv10 no-tlsv11 no-tls-tickets'

  contain ::profile::services::haproxy::firewall
  include ::profile::services::haproxy::logging
  include ::profile::services::haproxy::logrotate

  class { '::haproxy':
    merge_options    => true,
    global_options   => {
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
    defaults_options => {
      'option' => [ 'forwardfor', 'redispatch', ],
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
}
