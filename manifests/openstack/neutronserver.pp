# Installs and configures the neutron service on an openstack controller node
# in the SkyHiGh architecture. This class installs both the API and the neutron
# agents.
class profile::openstack::neutronserver {
  $password = hiera('profile::mysql::neutronpass')
  $neutron_password = hiera('profile::neutron::keystone::password')
  $nova_password = hiera('profile::nova::keystone::password')
  $allowed_hosts = hiera('profile::mysql::allowed_hosts')
  $keystone_public_ip = hiera('profile::api::keystone::public::ip')
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip')
  $mysql_ip = hiera('profile::mysql::ip')

  $region = hiera('profile::region')
  $admin_ip = hiera('profile::api::neutron::admin::ip')
  $public_ip = hiera('profile::api::neutron::public::ip')
  $vrid = hiera('profile::api::neutron::vrrp::id')
  $vrpri = hiera('profile::api::neutron::vrrp::priority')
  $vrrp_password = hiera('profile::keepalived::vrrp_password')
  $nova_admin_ip = hiera('profile::api::nova::admin::ip')
  $nova_public_ip = hiera('profile::api::nova::public::ip')
  $service_plugins = hiera('profile::neutron::service_plugins')
  $service_providers = hiera('profile::neutron::service_providers')
  $fw_driver = hiera('profile::neutron::fwaas_driver')
  $neutron_vrrp_pass = hiera('profile::neutron::vrrp_pass')
  $nova_metadata_secret = hiera('profile::nova::sharedmetadataproxysecret')
  $dns_servers = hiera('profile::nova::dns')

  $public_if = hiera('profile::interfaces::public')
  $management_if = hiera('profile::interfaces::management')
  $external_if = hiera('profile::interfaces::external')
  $mtu = hiera('profile::neutron::mtu', undef)

  $rabbit_user = hiera('profile::rabbitmq::rabbituser')
  $rabbit_pass = hiera('profile::rabbitmq::rabbitpass')
  $rabbit_ip = hiera('profile::rabbitmq::ip')

  $memcached_ip = hiera('profile::memcache::ip')

  $database_connection = "mysql://neutron:${password}@${mysql_ip}/neutron"

  require ::profile::mysql::cluster
  require ::profile::services::keepalived
  require ::profile::openstack::repo
  include ::profile::openstack::neutron::sudo
  include ::profile::openstack::neutron::tenant

  class { '::neutron':
    verbose                 => true,
    core_plugin             => 'ml2',
    allow_overlapping_ips   => true,
    service_plugins         => $service_plugins,
    dhcp_agents_per_network => 2,
    rabbit_password         => $rabbit_pass,
    rabbit_user             => $rabbit_user,
    rabbit_host             => $rabbit_ip,
    global_physnet_mtu      => $mtu,
  }

  class { 'neutron::db::mysql' :
    password      => $password,
    allowed_hosts => $allowed_hosts,
  }

#  neutron_config {
#    'DEFAULT/l3_ha': value => 'true';
#    'DEFAULT/max_l3_agents_per_router': value => '3';
#    'DEFAULT/min_l3_agents_per_router': value => '2';
#  }

  # Enable IPv6 prefix delegation for IPv6 support
  neutron_config {
    'DEFAULT/ipv6_pd_enabled': value => 'True';
  }
  package { 'dibbler-client':
    ensure => 'present',
  }

  class { '::neutron::keystone::auth':
    password     => $neutron_password,
    public_url   => "http://${public_ip}:9696",
    internal_url => "http://${admin_ip}:9696",
    admin_url    => "http://${admin_ip}:9696",
    region       => $region,
  }

  class { '::neutron::keystone::authtoken':
    password          => $neutron_password,
    auth_url          => "http://${keystone_admin_ip}:35357/",
    auth_uri          => "http://${keystone_public_ip}:5000/",
    memcached_servers => $memcached_ip,
    region_name       => $region,
  }

  class { '::neutron::agents::metadata':
    shared_secret => $nova_metadata_secret,
    metadata_ip   => $admin_ip,
    enabled       => true,
  }

  class { '::neutron::server':
    database_connection              => $database_connection,
    sync_db                          => true,
    allow_automatic_l3agent_failover => true,
    service_providers                => $service_providers,
  }

  class { '::neutron::agents::dhcp':
    dnsmasq_dns_servers => $dns_servers,
  }

  # Configure nova notifications system
  class { '::neutron::server::notifications':
    password    => $nova_password,
    auth_url    => "http://${keystone_admin_ip}:35357",
    region_name => $region,
    nova_url    => "http://${nova_public_ip}:8774/v2",
  }

  class { '::neutron::agents::l3':
    ha_enabled            => true,
    ha_vrrp_auth_password => $neutron_vrrp_pass,
  }

  class { '::neutron::services::fwaas':
    enabled => true,
    driver  => $fw_driver,
  }

  neutron_fwaas_service_config {
    'fwaas/agent_version': value => 'v1';
  }

  neutron_l3_agent_config {
    'AGENT/extensions': value => 'fwaas';
  }

  if($external_if == 'vlan') {
    $if = hiera('profile::interfaces::external::parentif')
    $id = hiera('profile::interfaces::external::vlanid')

    ::profile::infrastructure::ovs::patch {
      physical_if => $if,
      vlan_id     => $id,
      ovs_bridge  => 'br-ex',
    }
  } else {
    vs_port { $external_if:
      ensure => present,
      bridge => 'br-ex',
    }
  }

  keepalived::vrrp::script { 'check_neutron':
    script  => '/usr/bin/killall -0 neutron-server',
  }

  keepalived::vrrp::instance { 'admin-neutron':
    interface         => $management_if,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${admin_ip}/32",
    ],
    track_script      => 'check_neutron',
  }

  keepalived::vrrp::instance { 'public-neutron':
    interface         => $public_if,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${public_ip}/32",
    ],
    track_script      => 'check_neutron',
  }
}
