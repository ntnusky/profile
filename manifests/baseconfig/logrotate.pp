# Class to set defaults for logrotate
class profile::baseconfig::logrotate {
  class { '::logrotate':
    config             => {
      compress => true,
    }
  }
}
