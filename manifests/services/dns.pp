# Installs and configures a DNS server.
class profile::services::dns {
  $dns_forwarders = hiera('profile::dns::forwarders')
  $dns_zones = hiera_array('profile::dns::zones')

  include ::dns::server
  include ::profile::services::dashboard::clients::dns

  dns::server::options{'/etc/bind/named.conf.options':
    forwarders        => $dns_forwarders,
    dnssec_validation => 'no',
    dnssec_enable     => false,
  }

  file { '/var/lib/bind/zones':
    ensure => 'directory',
    owner  => 'bind',
    group  => 'bind',
    mode   => '0755',
  }

  ::profile::services::dns::zone { $dns_zones : }
}
