# Install and configure redis-cluster for sensu

class profile::services::redis {

  require ::firewall

  $nodetype = hiera('profile::redis::nodetype')
  $nic = hiera('profile::interfaces::management')
  $autoip = $::facts['networking']['interfaces'][$nic]['ip']
  $ip = hiera("profile::interfaces::${nic}::address", $autoip)
  $redismaster = hiera('profile::redis::master')
  $installsensu = hiera('profile::sensu::install', true)
  $masterauth = hiera('profile::redis::masterauth')

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
    masterauth          => $masterauth,
    requirepass         => $masterauth,
  }
  -> class { '::redis::sentinel':
    auth_pass        => $masterauth,
    down_after       => 5000,
    failover_timeout => 60000,
    redis_host       => $redismaster,
    log_file         => '/var/log/redis/redis-sentinel.log',
    sentinel_bind    => "${ip} 127.0.0.1",
  }

  profile::services::haproxy::tools::register { "Redis-${::fqdn}":
    servername  => $::hostname,
    backendname => 'bk_redis',
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

  if ($installsensu) {
    include ::profile::sensu::plugin::redis
    sensu::subscription { 'redis': }
  }
}
