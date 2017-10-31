# Haproxy config for redis

class profile::services::redis::haproxy {

  require ::profile::services::haproxy

  haproxy::frontend { 'ft_redis':
    ipaddress => '*',
    ports     => '6379',
    defaults  => 'redis',
    options   => {
      'default_backend' => 'bk_redis',
      'mode'            => 'tcp',
      'option'          => [
        'clitcpka',
        'srvtcpka',
      ],
    },
  }

  haproxy::backend { 'bk_redis':
    defaults => 'redis',
    options  => {
      'option'    => [
        'log-health-checks',
        'tcp-check',
        'tcplog',
      ],
      'tcp-check' => [
        'connect',
        'send PING\r\n',
        'expect string +PONG',
        'send info\ replication\r\n',
        'expect string role:master',
        'send QUIT\r\n',
        'expect string +OK',
      ],
    },
  }

  firewall { '050 accept redis-server':
    proto  => 'tcp',
    dport  => 6379,
    action => 'accept',
  }

}
