# Haproxy config for redis
class profile::services::redis::haproxy {
  include ::profile::services::redis::firewall

  $redisauth = lookup('profile::redis::masterauth')

  ::profile::services::haproxy::frontend { 'mysqlcluster':
    profile   => 'management',
    port      => 6379,
    ftoptions => {
      'option' => [
        'clitcpka',
        'srvtcpka',
      ],
    },
    bkoptions => {
      'option'    => [
        'log-health-checks',
        'tcp-check',
      ],
      'tcp-check' => [
        'connect',
        "send AUTH\\ ${redisauth}\\r\\n",
        'expect string +OK',
        'send PING\r\n',
        'expect string +PONG',
        'send info\ replication\r\n',
        'expect string role:master',
        'send QUIT\r\n',
        'expect string +OK',
      ],
    },
  }
}
