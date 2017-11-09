# This class installs the munin plugins which monitors puppet statistics 
class profile::monitoring::munin::plugin::puppet {
  ensure_packages ( [
      'python-yaml',
    ], {
      'ensure' => 'present',
    }
  )

  munin::plugin { 'puppet_lastrun':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/puppet_lastrun',
    config => [ 'user root' ],
  }
  munin::plugin { 'puppet_resources':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/puppet_resources',
    config => [ 'user root' ],
  }
  munin::plugin { 'puppet_resource_stat':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/puppet_resource_stat',
    config => [ 'user root' ],
  }
  munin::plugin { 'puppet_runtime':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/puppet_runtime',
    config => [ 'user root' ],
  }
}
