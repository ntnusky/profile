# Installs pgpool for HA postgres
class profile::services::postgresql::pgpool {
  package { 'pgpool2':
    ensure => present,
  }
}
