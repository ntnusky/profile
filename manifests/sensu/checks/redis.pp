# Sensu checks for redis servers
class profile::sensu::checks::redis {
  sensu::check { 'redis-slave-status':
    command     => 'check-redis-slave-status.rb -P ":::redis.masterauth:::"',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'redis' ],
  }
  sensu::check { 'redis-memory':
    command     => 'check-redis-memory-percentage.rb -P ":::redis.masterauth:::" -w :::redis.memwarn|80::: -c :::redis.memcrit|90:::',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'redis' ],
  }
  sensu::check { 'redis-ping':
    command     => 'check-redis-ping.rb -P ":::redis.masterauth:::"',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'redis' ],
  }
}
