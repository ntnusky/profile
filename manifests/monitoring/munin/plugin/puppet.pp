# This class installs the munin plugins which monitors puppet statistics 
class profile::monitoring::munin::plugin::puppet {
  munin::plugin { 'puppet_lastrun':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/puppet_lastrun',
  }
  munin::plugin { 'puppet_resources':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/puppet_resources',
  }
  munin::plugin { 'puppet_resource_stat':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/puppet_resource_stat',
  }
  munin::plugin { 'puppet_runtime':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/puppet_runtime',
  }
}
