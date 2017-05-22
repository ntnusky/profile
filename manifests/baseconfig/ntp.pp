# This class installs and configures NTP.
class profile::baseconfig::ntp {
  $ntpServer = hiera('profile::ntp::server')
  $tz = hiera('profile::ntp::timezone', 'Europe/Oslo')

  class { '::ntp':
    servers  => [ $ntpServer ],
    restrict => [
      'default kod nomodify notrap nopeer noquery',
      '-6 default kod nomodify notrap nopeer noquery',
    ],
  }

  file {'/etc/localtime':
    ensure => link,
    target => "/usr/share/zoneinfo/${tz}"
  }
}
