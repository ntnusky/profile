# This class installs and configures puppet.
class profile::baseconfig::puppet {
  $environment = hiera('profile::puppet::environment')
  $configtimeout = hiera('profile:puppet::configtimeout', '3m')
  $aptkey = hiera('profile::puppet::aptkey')

  if($::puppetversion < '4') {
    $agentConfigFile = '/etc/puppet/puppet.conf'
    $agentPackage = 'puppet'
  } else {
    $agentConfigFile = '/etc/puppetlabs/puppet/puppet.conf'
    $agentPackage = 'puppet-agent'
  }

  package { $agentPackage:
    ensure => 'present',
  }

  # This environment is not the one really used, as that is decided by
  # foreman's ENC, but puppet gets really sad if this setting points to a
  # non-existent environment. This setting might also get useful in the cases
  # where an ENC  is not used.
  ini_setting { 'Puppet environment':
    ensure  => present,
    path    => $agentConfigFile,
    section => 'agent',
    setting => 'environment',
    value   => $environment,
    notify  => Service['puppet'],
    require => Package[$agentPackage],
  }

  # This is to avoid ENC timeouts on nodes with hilarious amounts of facts...
  ini_setting { 'Puppet configtimeout':
    ensure  => 'present',
    path    => $agentConfigFile,
    section => 'agent',
    setting => 'configtimeout',
    value   => $configtimeout,
    require => Package[$agentPackage],
  }

  service { 'puppet':
    ensure  => 'running',
    enable  => true,
    require => Package[$agentPackage],
  }
}
