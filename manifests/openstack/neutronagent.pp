class profile::openstack::neutronagent {
  $password = hiera("profile::mysql::neutronpass")
  $keystone_ip = hiera("profile::api::keystone::public::ip")
  $mysql_ip = hiera("profile::mysql::ip")
  $neutron_pass = hiera("profile::neutron::keystone::password")

  $region = hiera("profile::region")
  $admin_ip = hiera("profile::api::neutron::admin::ip")
  $public_ip = hiera("profile::api::neutron::public::ip")
  $service_plugins = hiera("profile::neutron::service_plugins")
  
  $rabbit_hosts = hiera("controller::management::addresses")
  $rabbit_user = hiera("profile::rabbitmq::rabbituser")
  $rabbit_pass = hiera("profile::rabbitmq::rabbitpass")

  $database_connection = "mysql://neutron:${password}@${mysql_ip}/neutron"
  
  include ::profile::openstack::repo
  
  anchor{ "profile::openstack::neutronagent::begin" : }
  anchor{ "profile::openstack::neutronagent::end" : }

  class { '::neutron::agents::ml2::ovs':
    enable_tunneling => true,
    local_ip         => $::ipaddress_eth1,
    enabled          => true,
    tunnel_types     => ['gre'],
  }

  class { '::neutron':
    core_plugin           => 'ml2',
    allow_overlapping_ips => true,
    service_plugins       => $service_plugins,
    before                => Anchor["profile::openstack::neutronagent::end"],
    require               => Anchor["profile::openstack::neutronagent::begin"],
    rabbit_password       => $rabbit_pass,
    rabbit_user           => $rabbit_user,
    rabbit_hosts          => $rabbit_hosts,
  }
  
  class { '::neutron::keystone::auth':
    password         => $neutron_pass,
    public_address   => $public_ip,
    admin_address    => $admin_ip,
    internal_address => $admin_ip,
    before           => Anchor["profile::openstack::neutronagent::end"],
    require          => Anchor["profile::openstack::neutronagent::begin"],
    region           => $region,
  }
  
  class { '::neutron::server':
    enabled           => false,
    sync_db           => false,
    auth_password     => $neutron_pass,
    auth_uri          => "http://${keystone_ip}:5000/",
    connection        => $database_connection,
    before            => Anchor["profile::openstack::neutronagent::end"],
    require           => Anchor["profile::openstack::neutronagent::begin"],
  }
}
