# Haproxy config for redis

class profile::services::redis::haproxy {

  require ::profile::services::haproxy

  haproxy::defaults { 'redis':
    options => {
      'log'     => 'global',
      'mode'    => 'tcp',
      'timeout' => [
        'connect 5s',
        'server 2m',
        'client 2m',
      ],
      'option'  => [
        'log-health-checks',
        'tcplog',
        'clitcpka',
        'srvtcpka',
      ],
    },
  }

  haproxy::frontend { 'ft_redis':
    ipaddress => '*',
    ports     => '6379',
    defaults  => 'redis',
    options   => {
      'default_backend' => 'bk_redis',
    },
  }

  haproxy::backend { 'bk_redis':
    defaults => 'redis',
    options  => {
      'option'    => [
        'tcp-check',
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
