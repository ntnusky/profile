# Uninstall keepalived
class profile::services::keepalived::uninstall {
  package { 'keepalived':
    ensure => 'purged',
  }

  service { 'keepalived':
    ensure => 'stopped',
    before => Package['keepalived'],
  }
}
