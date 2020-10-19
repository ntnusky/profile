# This class installs and configures NTP.
class profile::baseconfig::ntp {
  $installsensu = lookup('profile::sensu::install')
  $ntpservers = lookup('profile::ntp::servers')
  $tz = lookup('profile::ntp::timezone', {
    'value_type'    => String,
    'default_value' => 'Europe/Oslo'
  })

  case $::operatingsystem {
    'CentOS': {
      class { '::chrony':
        servers => $ntpservers
      }
      if($installsensu) {
        sensu::subscription { 'chrony': }
      }
    }
    'Ubuntu': {
      class { '::ntp':
        servers  => $ntpservers,
        restrict => [
          '127.0.0.1',
          '-6 ::1',
          'default kod nomodify notrap nopeer noquery',
          '-6 default kod nomodify notrap nopeer noquery',
        ],
      }
      if($installsensu) {
        sensu::subscription { 'ntpd': }
      }
    }
    default: {
      fail("Unsopperted operating system: ${::operatingsystem}")
    }
  }

  class { '::timezone':
    timezone => $tz,
  }
}
