# This class installs and configures firewall.
class profile::baseconfig::firewall {
  Firewall {
    before  => Class['::profile::baseconfig::firewall::post'],
    require => Class['::profile::baseconfig::firewall::pre'],
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
  
  include ::profile::baseconfig::firewall::pre
  include ::profile::baseconfig::firewall::post
  
  include ::firewall
}

