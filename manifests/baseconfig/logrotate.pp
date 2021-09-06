# Class to set defaults for logrotate
class profile::baseconfig::logrotate {
  logrotate::conf { '/etc/logrotate.conf':
    compress => true,
  }
}
