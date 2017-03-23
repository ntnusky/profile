# Sensu check definitions
class profile::sensu::checks {

  $keystone_api = hiera('profile::api::keystone::public::ip')
  $nova_api = hiera ('profile::api::nova::public::ip')
  $neutron_api = hiera('profile::api::neutron::public::ip')
  $cinder_api = hiera('profile::api::cinder::public::ip')
  $glance_api = hiera('profile::api::glance::public::ip')
  $heat_api = hiera('profile::api::heat::public::ip')

  # Base checks for all hosts
  sensu::check { 'diskspace':
    command     => 'check-disk-usage.rb -w :::disk.warning|80::: -c :::disk.critical|90::: -I :::disk.mountpoints|all:::',
    standalone  => false,
    subscribers => [ 'all' ],
  }

  sensu::check { 'load':
    command     => 'check-load.rb -w :::load.warning|1,5,10::: -c :::load.critical|10,15,25:::',
    standalone  => false,
    subscribers => [ 'all'],
  }

  sensu::check { 'memory':
    command     => 'check-memory-percent.rb -w :::memory.warning|85::: -c :::memory.critical|90:::',
    standalone  => false,
    subscribers => [ 'all' ],
  }

  # Physical servers only checks
  sensu::check { 'general-hw-error':
    command     => 'check-hardware-fail.rb',
    standalone  => false,
    subscribers => [ 'physical-servers' ],
  }

  sensu::check { 'check-raid':
    command     => '/etc/sensu/plugins/extra/check_raid.pl --noraid=OK',
    standalone  => false,
    subscribers => [ 'physical-servers' ],
  }

    #  sensu::check { 'cciss-raid-health':
    #command     => '/etc/sensu/plugins/extra/check_cciss.sh -v -p',
    #standalone  => false,
    #subscribers => [ 'cciss' ],
    #}

  # Ceph checks
  sensu::check { 'ceph-health':
    command     => 'sudo check-ceph.rb -d',
    standalone  => false,
    subscribers => [ 'roundrobin:ceph' ],
  }

  # MySQL cluster checks
  sensu::check { 'mysql-status':
    aggregate   => 'galera-cluster',
    command     => 'check-mysql-status.rb -h localhost -d mysql -u clustercheck -p :::mysql.password::: --check status',
    handle      => false,
    standalone  => false,
    subscribers => [ 'mysql' ],
  }

  # Rabbitmq checks
  sensu::check { 'rabbitmq-alive':
    command     => 'check-rabbitmq-alive.rb',
    standalone  => false,
    subscribers => [ 'rabbitmq' ],
  }

  sensu::check { 'rabbitmq-node-health':
    command     => 'check-rabbitmq-node-health.rb -m :::rabbitmq.memwarn|80::: -c :::rabbitmq.memcrit|90::: -f :::rabbitmq.fdwarn|80::: -F :::rabbitmq.fdcrit|90::: -s :::rabbitmq.socketwarn|80::: -S :::rabbitmq.socketcrit|90:::',
    standalone  => false,
    subscribers => [ 'rabbitmq' ],
  }

  sensu::check { 'rabbitmq-queue-drain-time':
    command     => 'check-rabbitmq-queue-drain-time.rb -w :::rabbitmq.queuewarn|180::: -c :::rabbitmq.queuecrit|360:::',
    standalone  => false,
    subscribers => [ 'rabbitmq' ],
  }

  # Openstack API checks
  sensu::check { 'openstack-identityv3-api':
    command     => "check-http.rb -u http://${keystone_api}:5000/v3",
    standalone  => false,
    subscribers => [ 'os-api-checks' ],
  }
  sensu::check { 'openstack-identity-api':
    command     => "check-http.rb -u http://${keystone_api}:5000/v2.0",
    standalone  => false,
    subscribers => [ 'os-api-checks' ],
  }
  sensu::check { 'openstack-network-api':
    command     => "check-http.rb -u http://${neutron_api}:9696/v2.0 --response-code 401",
    standalone  => false,
    subscribers => [ 'os-api-checks' ],
  }
  sensu::check { 'openstack-image-api':
    command     => "check-http.rb -u http://${glance_api}:9292/v2 --response-code 401",
    standalone  => false,
    subscribers => [ 'os-api-checks' ],
  }
  sensu::check { 'openstack-orchestration-api':
    command     => "check-http.rb -u http://${heat_api}:8004/v1 --response-code 401",
    standalone  => false,
    subscribers => [ 'os-api-checks' ],
  }
  sensu::check { 'openstack-volumev3-api':
    command     => "check-http.rb -u http://${cinder_api}:8776/v3 --response-code 401",
    standalone  => false,
    subscribers => [ 'os-api-checks' ],
  }
  sensu::check { 'openstack-compute-api':
    command     => "check-http.rb -u http://${nova_api}:8774/v2.1/v3 --response-code 401",
    standalone  => false,
    subscribers => [ 'os-api-checks' ],
  }

  # OpenStack Infrastructure checks
  sensu::check { 'openstack-floating-ip':
    command     => "/etc/sensu/plugins/extra/check_os_floating_ip.sh -p :::os.password::: -u http://${keystone_api}:5000/v3 -s :::os.floating-subnet::: -w :::os.floating-warn|100::: -c :::os.floating-critical|50:::",
    standalone  => false,
    subscribers => [ 'os-infra-checks '],
  }
}
