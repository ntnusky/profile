# Class to set defaults for logrotate
class profile::baseconfig::logrotate {
  #logrotate::conf { '/etc/logrotate.conf':
  #  compress => true,
  #}

  class { '::logrotate':
    create_base_rules  => false,
    manage_cron_daily  => false,
    manage_cron_hourly => false,
    config             => {
      compress => true,
    }
  }
}
