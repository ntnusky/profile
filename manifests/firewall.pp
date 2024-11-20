# This class installs and configures a basic firewall-framework.
class profile::firewall {
  Firewall {
    before  => Class['::profile::firewall::common::post'],
    require => Class['::profile::firewall::common::pre'],
  }

  firewallchain { 'INPUT:filter:IPv4':
    ensure => present,
    policy => accept,
    purge  => true,
  }
  
  firewallchain { 'INPUT:filter:IPv6':
    ensure => present,
    policy => accept,
    purge  => true,
  }
  
  include ::firewall
  include ::profile::firewall::common::pre
  include ::profile::firewall::common::post
}

