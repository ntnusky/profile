# Install and configure redis-cluster for sensu

class profile::services::redis {

  require ::firewall

  $nodetype = hiera('profile::redis::nodetype')
  $nic = hiera('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$nic]['ip']
  $redismaster = hiera('profile::redis::master')

  if ( $nodetype == 'slave' ) {
    $slaveof = "${redismaster} 6379"
  }
  elsif ( $nodetype == 'master') {
    $slaveof = undef
  }
  else {
    fail('Wrong redis node type. Only master or slave are valid')
  }

  class { '::redis':
    config_owner        => 'redis',
    config_group        => 'redis',
    manage_repo         => true,
    bind                => "${ip} 127.0.0.1",
    min_slaves_to_write => 1,
    slaveof             => $slaveof,
  } ->

  class { '::redis::sentinel':
    down_after       => 5000,
    failover_timeout => 60000,
    redis_host       => $redismaster,
    log_file         => '/var/log/redis/redis-sentinel.log',
    sentinel_bind    => "${ip} 127.0.0.1",
  }

  @@haproxy::balancermember { $::fqdn:
    listening_service => 'bk_redis',
    ports             => '6379',
    ipaddresses       => $ip,
    server_names      => $::hostname,
    options           => [
      'backup check inter 1s',
    ],
  }

  firewall { '050 accept redis-server':
    proto  => 'tcp',
    dport  => 6379,
    action => 'accept',
  }
  firewall { '051 accept redis-sentinel':
    proto  => 'tcp',
    dport  => 26379,
    action => 'accept',
  }
}
