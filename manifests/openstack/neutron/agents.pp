# Installs and configures the neutron agents
class profile::openstack::neutron::agents {
  $admin_ip = hiera('profile::api::neutron::admin::ip')
  $neutron_vrrp_pass = hiera('profile::neutron::vrrp_pass')
  $nova_metadata_secret = hiera('profile::nova::sharedmetadataproxysecret')
  $dns_servers = hiera('profile::nova::dns')

  require ::profile::openstack::neutron::base
  require ::profile::openstack::neutron::firewall
  require ::profile::openstack::repo

  class { '::neutron::agents::metadata':
    shared_secret => $nova_metadata_secret,
    metadata_ip   => $admin_ip,
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
