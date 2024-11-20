# This class installs and configures NTP.
class profile::baseconfig::ntp {
  $ntpservers = lookup('profile::ntp::servers')
  $tz = lookup('profile::ntp::timezone', {
    'value_type'    => String,
    'default_value' => 'Europe/Oslo'
  })

  class { '::chrony':
    servers => $ntpservers
  }

  class { '::timezone':
    timezone => $tz,
  }
}
