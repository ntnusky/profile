# Uninstall and cleanup sensu-client
class profile::sensu::client::uninstall {
  package { 'sensu':
    ensure => purged,
  }

  file { '/etc/sensu':
    ensure => absent,
  }

  user { 'sensu':
    ensure => absent,
  }

  group { 'sensu':
    ensure => absent,
  }
}
