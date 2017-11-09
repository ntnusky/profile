# This class installs and configures NTP.
class profile::baseconfig::ntp {
  $ntpServers = hiera('profile::ntp::servers')
  $tz = hiera('profile::ntp::timezone', 'Europe/Oslo')

  class { '::ntp':
    servers  => $ntpServers,
    restrict => [
      '127.0.0.1',
      '-6 ::1',
      'default kod nomodify notrap nopeer noquery',
      '-6 default kod nomodify notrap nopeer noquery',
    ],
  }

  file {'/etc/localtime':
    ensure => link,
    target => "/usr/share/zoneinfo/${tz}"
  }
}
