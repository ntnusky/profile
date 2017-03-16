# Sensu check definitions
class profile::sensu::checks {
  sensu::check { 'diskspace':
    command     =>
      'check-disk-usage.rb \
      -w :::disk.warning|80::: \
      -c :::disk.critical|90::: \
      -I :::disk.mountpoints|all:::',
    subscribers => [ 'all' ],
  }
}
