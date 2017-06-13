# Configures neutron to allow IPv6 delegation to tenant subnets trough dhcpv6-pd
class profile::openstack::neutron::ipv6 {
  neutron_config {
    'DEFAULT/ipv6_pd_enabled': value => 'True';
  }
  package { 'dibbler-client':
    ensure => 'present',
  }
}
