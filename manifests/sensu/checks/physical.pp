# Sensu checks intended for all physical servers
class profile::sensu::checks::physical {
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
}
