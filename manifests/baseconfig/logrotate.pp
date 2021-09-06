# Class to set defaults for logrotate
class profile::baseconfig::logrotate {
  logrotate::conf { '/etc/logrotate.conf':
    compress => true,
    su       => $::logrotate::params::default_su,
    su_user  => $::logrotate::params::default_su_user,
    su_group => $::logrotate::params::default_su_group,
  }
}
