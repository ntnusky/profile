# This class installs and configures puppet.
class profile::baseconfig::puppet {
  $environment = hiera('profile::puppet::environment')
  $configtimeout = hiera('profile:puppet::configtimeout', '3m')
  $aptkey = hiera('profile::puppet::aptkey')
  $runinterval = hiera('profile::puppet::runinterval', '30m')
  $puppetserver = hiera('profile::puppet::hostname')
  $caserver = hiera('profile::puppet::caserver')

  if($::puppetversion < '4') {
    $agentconfigfile = '/etc/puppet/puppet.conf'
    $agentpackage = 'puppet'
  } else {
    $agentconfigfile = '/etc/puppetlabs/puppet/puppet.conf'
    $agentpackage = 'puppet-agent'
  }

  package { $agentpackage:
    ensure => 'present',
  }

  # This environment is not the one really used, as that is decided by
  # foreman's ENC, but puppet gets really sad if this setting points to a
  # non-existent environment. This setting might also get useful in the cases
  # where an ENC  is not used.
  ini_setting { 'Puppet environment':
    ensure  => present,
    path    => $agentconfigfile,
    section => 'agent',
    setting => 'environment',
    value   => $environment,
    notify  => Service['puppet'],
    require => Package[$agentpackage],
  }

  ini_setting { 'Puppet run interval':
    ensure  => present,
    path    => $agentconfigfile,
    section => 'agent',
    setting => 'runinterval',
    value   => $runinterval,
    notify  => Service['puppet'],
    require => Package[$agentpackage],
  }

  ini_setting { 'Puppet server':
    ensure  => present,
    path    => $agentconfigfile,
    section => 'agent',
    setting => 'server',
    value   => $puppetserver,
    notify  => Service['puppet'],
    require => Package[$agentpackage],
  }

  ini_setting { 'Puppet caserver':
    ensure  => present,
    path    => $agentconfigfile,
    section => 'agent',
    setting => 'ca_server',
    value   => $caserver,
    notify  => Service['puppet'],
    require => Package[$agentpackage],
  }

  if($::puppetversion < '4') {
    # This is to avoid ENC timeouts on nodes with hilarious amounts of facts...
    ini_setting { 'Puppet configtimeout':
      ensure  => 'present',
      path    => $agentconfigfile,
      section => 'agent',
      setting => 'configtimeout',
      value   => $configtimeout,
      require => Package[$agentpackage],
    }
  } else {
    ini_setting { 'Puppet configtimeout':
      ensure  => 'absent',
      path    => $agentconfigfile,
      section => 'agent',
      setting => 'configtimeout',
      require => Package[$agentpackage],
    }
  }

  service { 'puppet':
    ensure  => 'running',
    enable  => true,
    require => Package[$agentpackage],
  }
}
