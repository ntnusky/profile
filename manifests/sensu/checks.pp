# Sensu check definitions
class profile::sensu::checks {

  $keystone_api = hiera('profile::api::keystone::public::ip')
  $nova_api = hiera ('profile::api::nova::public::ip')
  $neutron_api = hiera('profile::api::neutron::public::ip')
  $cinder_api = hiera('profile::api::cinder::public::ip')
  $glance_api = hiera('profile::api::glance::public::ip')
  $heat_api = hiera('profile::api::heat::public::ip')

  $puppet_runinterval = Integer(hiera('profile::puppet::runinterval')[0,-2])*60
  $puppetwarn = $puppet_runinterval*3
  $puppetcrit = $puppet_runinterval*10

  $memcached_ip = hiera('profile::memcache::ip','127.0.0.1')

  # Base checks for all hosts
  sensu::check { 'diskspace':
    command     => 'check-disk-usage.rb -w :::disk.warning|80::: -c :::disk.critical|90::: -I :::disk.mountpoints|all:::',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'all' ],
  }

  sensu::check { 'load':
    command     => 'check-load.rb -w :::load.warning|1.7,1.6,1.5::: -c :::load.critical|1.9,1.8,1.7:::',
    standalone  => false,
    interval    => 300,
    subscribers => [ 'all'],
  }

  sensu::check { 'memory':
    command     => 'check-memory-percent.rb -w :::memory.warning|85::: -c :::memory.critical|90:::',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'all' ],
  }

  sensu::check { 'puppetrun':
    command     => "sudo check-puppet-last-run.rb -r -w :::puppet.warn|${puppetwarn}::: -c :::puppet.crit|${puppetcrit}:::",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'all' ],
  }

  sensu::check { 'ntp-offset':
    command     => 'check-ntp.rb -w :::ntp.warn|10::: -c :::ntp.crit|100:::',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'all' ],
  }

  # Physical servers only checks
  sensu::check { 'general-hw-error':
    command     => 'check-hardware-fail.rb',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'physical-servers' ],
  }

  sensu::check { 'check-raid':
    command     => '/etc/sensu/plugins/extra/check_raid.pl --noraid=OK',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'physical-servers' ],
  }

  # Physical Dell Servers checks
  sensu::check { 'rac-system-event-log':
    command     => '/etc/sensu/plugins/extra/check_rac_sel.sh -h :::rac.ip::: -p :::rac.password:::',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'dell-servers' ],
  }

  # Ceph checks
  sensu::check { 'ceph-health':
    command     => 'sudo check-ceph.rb -d',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'roundrobin:ceph' ],
  }

  # MySQL cluster checks
  sensu::check { 'mysql-status':
    aggregate   => 'galera-cluster',
    command     => 'check-mysql-status.rb -h localhost -d mysql -u clustercheck -p :::mysql.password::: --check status',
    interval    => 300,
    handle      => false,
    standalone  => false,
    subscribers => [ 'mysql' ],
  }

  # Rabbitmq checks
  sensu::check { 'rabbitmq-alive':
    command     => 'check-rabbitmq-alive.rb',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'rabbitmq' ],
  }

  sensu::check { 'rabbitmq-node-health':
    command     => 'check-rabbitmq-node-health.rb -m :::rabbitmq.memwarn|80::: -c :::rabbitmq.memcrit|90::: -f :::rabbitmq.fdwarn|80::: -F :::rabbitmq.fdcrit|90::: -s :::rabbitmq.socketwarn|80::: -S :::rabbitmq.socketcrit|90:::',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'rabbitmq' ],
  }

  sensu::check { 'rabbitmq-queue-drain-time':
    command     => 'check-rabbitmq-queue-drain-time.rb -w :::rabbitmq.queuewarn|180::: -c :::rabbitmq.queuecrit|360:::',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'rabbitmq' ],
  }

  # Openstack API checks
  sensu::check { 'openstack-identityv3-api':
    command     => "check-http.rb -u http://${keystone_api}:5000/v3",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-api-checks' ],
  }
  sensu::check { 'openstack-identity-api':
    command     => "check-http.rb -u http://${keystone_api}:5000/v2.0",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-api-checks' ],
  }
  sensu::check { 'openstack-network-api':
    command     => "check-http.rb -u http://${neutron_api}:9696/v2.0 --response-code 401",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-api-checks' ],
  }
  sensu::check { 'openstack-image-api':
    command     => "check-http.rb -u http://${glance_api}:9292/v2 --response-code 401",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-api-checks' ],
  }
  sensu::check { 'openstack-orchestration-api':
    command     => "check-http.rb -u http://${heat_api}:8004/v1 --response-code 401",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-api-checks' ],
  }
  sensu::check { 'openstack-volumev3-api':
    command     => "check-http.rb -u http://${cinder_api}:8776/v3 --response-code 401",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-api-checks' ],
  }
  sensu::check { 'openstack-compute-api':
    command     => "check-http.rb -u http://${nova_api}:8774/v2.1/v3 --response-code 401",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-api-checks' ],
  }
  sensu::check { 'openstack-placement-api':
    command     => "check-http.rb -u http://${nova_api}:8778/placement --response-code 401",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-api-checks' ],
  }

  # OpenStack Infrastructure checks
  sensu::check { 'openstack-floating-ip':
    command     => "/etc/sensu/plugins/extra/check_os_floating_ip.sh -p :::os.password::: -u http://${keystone_api}:5000/v3 -s :::os.floating-subnet::: -w :::os.floating-warn|100::: -c :::os.floating-critical|50:::",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'os-infra-checks'],
  }

  # HAProxy checks
  sensu::check { 'haproxy-stats':
    command     => 'check-haproxy.rb -S localhost -q / -P 9000 -A',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'haproxy-servers' ],
  }

  # Redis checks
  sensu::check { 'redis-slave-status':
    command     => 'check-redis-slave-status.rb',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'redis' ],
  }
  sensu::check { 'redis-memory':
    command     => 'check-redis-memory-percentage.rb -w :::redis.memwarn|80::: -c :::redis.memcrit|90:::',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'redis' ],
  }
  sensu::check { 'redis-ping':
    command     => 'check-redis-ping.rb',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'redis' ],
  }

  # memcached checks
  sensu::check { 'memcached-status':
    command     => "check-memcached-stats.rb -h ${memcached_ip}",
    interval    => 300,
    standalone  => false,
    subscribers => [ 'memcached-ext' ],
  }
}
