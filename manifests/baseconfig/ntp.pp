# This class installs and configures NTP.
class profile::baseconfig::ntp {
  $installsensu = lookup('profile::sensu::install')
  $ntpservers = lookup('profile::ntp::servers')
  $tz = lookup('profile::ntp::timezone', {
    'value_type'    => String,
    'default_value' => 'Europe/Oslo'
  })

  $rel = $facts['os']['release']['major']
  if ($rel == 18.04) {
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
  } else {
    class { '::chrony':
      servers => $ntpservers
    }
    if($installsensu) {
      sensu::subscription { 'chrony': }
    }
  }

  class { '::timezone':
    timezone => $tz,
  }
}
