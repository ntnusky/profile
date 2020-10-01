# This class installs and configures NTP.
class profile::baseconfig::ntp {
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
    }
    default: {
      fail("Unsopperted operating system: ${::operatingsystem}")
    }
  }

  class { '::timezone':
    timezone => $tz,
  }
}
