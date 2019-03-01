# Sensu checks intended for all nodes
class profile::sensu::checks::base {

  $puppet_runinterval = Integer(lookup('profile::puppet::runinterval')[0,-2])*60
  $puppetwarn = $puppet_runinterval*3
  $puppetcrit = $puppet_runinterval*10

  sensu::check { 'diskspace':
    command     => 'check-disk-usage.rb -w :::disk.warning|80::: -c :::disk.critical|90::: -t ext2,ext3,ext4,xfs -i :::disk.ignore|none:::',
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

  sensu::check { 'dns':
    command     => 'check-dns.rb -d :::dns.domain|ntnu.no:::',
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

  sensu::check { 'puppet-process':
    command     => 'check-process.rb -p "puppet agent" -w2 -c3',
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
}
