# Sensu checks intended for physical Dell Servers only
class profile::sensu::checks::dell {
  sensu::check { 'rac-system-event-log':
    command     => '/etc/sensu/plugins/extra/check_rac_sel.sh -h :::rac.ip::: -p :::rac.password:::',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'dell-servers' ],
  }
}
