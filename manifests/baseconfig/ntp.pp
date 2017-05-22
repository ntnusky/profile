# This class installs and configures NTP.
class profile::baseconfig::ntp {
  $ntpServer = hiera('profile::ntp::server')
  class { '::ntp':
    servers  => [ $ntpServer ],
    restrict => [
      'default kod nomodify notrap nopeer noquery',
      '-6 default kod nomodify notrap nopeer noquery',
    ],
  }
}
