# Class to set defaults for logrotate
class profile::baseconfig::logrotate {

  include ::logrotate::params

  logrotate::conf { '/etc/logrotate.conf':
    compress => true,
  }
}
