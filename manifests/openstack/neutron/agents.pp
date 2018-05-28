# Installs and configures the neutron agents
class profile::openstack::neutron::agents {
  $adminlb_ip = hiera('profile::haproxy::management::ipv4')
  $dns_servers = hiera('profile::nova::dns')
  $neutron_vrrp_pass = hiera('profile::neutron::vrrp_pass')
  $nova_metadata_secret = hiera('profile::nova::sharedmetadataproxysecret')

  require ::profile::openstack::neutron::base
  require ::profile::openstack::neutron::firewall::l3agent
  require ::profile::openstack::repo

  class { '::neutron::agents::metadata':
    shared_secret => $nova_metadata_secret,
    metadata_ip   => $adminlb_ip,
    enabled       => true,
  }

  class { '::neutron::agents::dhcp':
    dnsmasq_dns_servers => $dns_servers,
  }

  class { '::neutron::agents::l3':
    ha_enabled            => true,
    ha_vrrp_auth_password => $neutron_vrrp_pass,
  }
}
