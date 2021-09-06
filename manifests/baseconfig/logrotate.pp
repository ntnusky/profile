# Class to set defaults for logrotate
class profile::baseconfig::logrotate {
  include ::logrotate
  #  class { '::logrotate':
  #    config             => {
  #      compress => true,
  #    }
  #  }
}
