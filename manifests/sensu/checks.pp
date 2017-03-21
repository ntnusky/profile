# Sensu check definitions
class profile::sensu::checks {

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

  sensu::check { 'cciss-raid-health':
    command     => '/etc/sensu/plugins/extra/check_cciss.sh -v -p',
    standalone  => false,
    subscribers => [ 'cciss' ],
  }

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
}
