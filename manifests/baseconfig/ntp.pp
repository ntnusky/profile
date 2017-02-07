# This class installs and configures NTP.
class profile::baseconfig::ntp {
  class { '::ntp':
    servers  => [ 'ntp.hig.no'],
    restrict => [
      'default kod nomodify notrap nopeer noquery',
      '-6 default kod nomodify notrap nopeer noquery',
    ],
  }
}
