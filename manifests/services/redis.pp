# Install and configure redis-cluster for sensu

class profile::services::redis {

  require ::firewall

  $nodetype = lookup('profile::redis::nodetype', Enum['slave', 'master'])
  $nic = lookup('profile::interfaces::management', String)
  $autoip = $::facts['networking']['interfaces'][$nic]['ip']
  $ip = lookup("profile::baseconfig::network::interfaces.${nic}.ipv4.address", {
    'value_type'    => Stdlib::IP::Address::V4,
    'default_value' => $autoip
    })
  $redismaster = lookup('profile::redis::master', Stdlib::IP::Address::V4)
  $installsensu = lookup('profile::sensu::install', {
    'value_type'    => Boolean,
    'default_value' => true
    })
  $masterauth = lookup('profile::redis::masterauth', String)

  if ( $nodetype == 'slave' ) {
    $slaveof = "${redismaster} 6379"
  }
  elsif ( $nodetype == 'master') {
    $slaveof = undef
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
