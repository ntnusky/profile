# Installs ipmitool
class profile::utilities::ipmitool {
  package { 'ipmitool':
    ensure => 'present',
  }
}
