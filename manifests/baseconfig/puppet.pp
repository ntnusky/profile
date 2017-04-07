# This class installs and configures puppet.
class profile::baseconfig::puppet {
  $environment = hiera('profile::puppet::environment')
  $configtimeout = hiera('profile:puppet::configtimeout', '3m')

  # If we are running on ubuntu 14.04, add the puppet repos to get puppet 3.8.
  if ($::lsbdistcodename == 'trusty') {
    apt::source { 'puppetlabs':
      location   => 'http://apt.puppetlabs.com',
      repos      => 'main',
      key        => '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
      key_server => 'pgp.mit.edu',
      before     => Package['puppet'],
    }
  }

  package { 'puppet':
    ensure => 'present',
  }

  ini_setting { 'Puppet Start':
    ensure  => present,
    path    => '/etc/default/puppet',
    section => '',
    setting => 'START',
    value   => 'yes',
    require => Package['puppet'],
  }

  # This environment is not the one really used, as that is decided by
  # foreman's ENC, but puppet gets really sad if this setting points to a
  # non-existent environment. This setting might also get useful in the cases
  # where an ENC  is not used.
  ini_setting { 'Puppet environment':
    ensure  => present,
    path    => '/etc/puppet/puppet.conf',
    section => 'agent',
    setting => 'environment',
    value   => $environment,
    notify  => Service['puppet'],
    require => Package['puppet'],
  }

  # This is to avoid ENC timeouts on nodes with hilarious amounts of facts...
  ini_setting { 'Puppet configtimeout':
    ensure  => 'present',
    path    => '/etc/puppet/puppet.conf',
    section => 'agent',
    setting => 'configtimeout',
    value   => $configtimeout,
    require => Package['puppet'],
  }

  service { 'puppet':
    ensure  => 'running',
    require => Package['puppet'],
  }
}
