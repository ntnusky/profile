# Sensu check definitions
class profile::sensu::checks {
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

  sensu::check { 'general-hw-error':
    command     => 'check-hardware-fail.rb',
    standalone  => false,
    subscribers => [ 'physical-servers' ],
  }
}