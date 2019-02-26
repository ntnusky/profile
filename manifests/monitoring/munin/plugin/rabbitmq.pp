# Munin plugins for rabbitmq
class profile::monitoring::munin::plugin::rabbitmq {
  munin::plugin { 'rabbit_connections':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/rabbit_connections',
    config => ['user root'],
  }
  munin::plugin { 'rabbit_fd':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/rabbit_fd',
    config => ['user root'],
  }
  munin::plugin { 'rabbit_processes':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/rabbit_processes',
    config => ['user root'],
  }
  munin::plugin { 'rabbit_memory':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/rabbit_memory',
    config => ['user root'],
  }
}
