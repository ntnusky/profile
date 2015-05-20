class profile::openstack::neutronserver {
  $password = hiera("profile::mysql::neutronpass")
  $nova_password = hiera("profile::mysql::novapass")
  $allowed_hosts = hiera("profile::mysql::allowed_hosts")
  $keystone_ip = hiera("profile::api::keystone::public::ip")
  $mysql_ip = hiera("profile::mysql::ip")

  $region = hiera("profile::region")
  $admin_ip = hiera("profile::api::neutron::admin::ip")
  $public_ip = hiera("profile::api::neutron::public::ip")
  $nova_admin_ip = hiera("profile::api::nova::admin::ip")
  $nova_public_ip = hiera("profile::api::nova::public::ip")
  
  $rabbit_user = hiera("profile::rabbitmq::rabbituser")
  $rabbit_pass = hiera("profile::rabbitmq::rabbitpass")

  $database_connection = "mysql://neutron:${password}@${mysql_ip}/neutron"
  
  include ::profile::openstack::repo
  
  anchor { "profile::openstack::neutron::begin" : 
    require => [ Anchor["profile::mysqlcluster::end"], ],
  }
  
  class { '::neutron':
    verbose               => true,
    allow_overlapping_ips => true,
    service_plugins       => [ 'dhcp', 'l3' ],
    before                => Anchor["profile::openstack::neutron::end"],
    require               => Anchor["profile::openstack::neutron::begin"],
    rabbit_password       => $rabbit_pass,
    rabbit_user           => $rabbit_user,
    rabbit_host           => 'localhost',
  }
  
  class { '::neutron::keystone::auth':
    password         => $password,
    public_address   => $public_ip,
    admin_address    => $admin_ip,
    internal_address => $admin_ip,
    before           => Anchor["profile::openstack::neutron::end"],
    require          => Anchor["profile::openstack::neutron::begin"],
  }
  
  # HACK: Should be moved!!! (i guess?)
  class { '::nova::keystone::auth':
    password         => $nova_password,
    public_address   => $nova_public_ip,
    admin_address    => $nova_admin_ip,
    internal_address => $nova_admin_ip,
    before           => Anchor["profile::openstack::neutron::end"],
    require          => Anchor["profile::openstack::neutron::begin"],
  }
  
  class { '::neutron::server':
    enabled           => false,
    manage_service    => false,
    auth_password     => $password,
    auth_uri          => "http://${keystone_ip}:5000/",
    connection        => $database_connection,
    before            => Anchor["profile::openstack::neutron::end"],
    require           => Anchor["profile::openstack::neutron::begin"],
  }
  
  class { '::neutron::agents::dhcp':
    enabled        => false,
    manage_service => false,
    before         => Anchor["profile::openstack::neutron::end"],
    require        => Anchor["profile::openstack::neutron::begin"],
  }
  
  # Configure nova notifications system
  class { '::neutron::server::notifications':
    nova_admin_password    => $password,
    before                 => Anchor["profile::openstack::neutron::end"],
    require                => Class["::nova::keystone::auth"],
  }

  # This plugin configures Neutron for OVS on the server
  # Agent
  class { '::neutron::agents::ml2::ovs':
    local_ip         => $::ipaddress_eth3,
    enable_tunneling => true,
    before           => Anchor["profile::openstack::neutron::end"],
    require          => Anchor["profile::openstack::neutron::begin"],
  }

  # Plugin
  #class { '::neutron::plugins::ovs':
  #  tenant_network_type => 'gre',
  #  before         => Anchor["profile::openstack::neutron::end"],
  #  require        => Anchor["profile::openstack::neutron::begin"],
  #}

  # ml2 plugin with vxlan as ml2 driver and ovs as mechanism driver
  class { '::neutron::plugins::ml2':
    type_drivers         => ['gre'],
    tenant_network_types => ['gre'],
    mechanism_drivers    => ['openvswitch'],
    tunnel_id_ranges     => ['100:999'],
    before         => Anchor["profile::openstack::neutron::end"],
    require        => Anchor["profile::openstack::neutron::begin"],
  }
  
  class { '::neutron::agents::l3':
    enabled        => false,
    manage_service => false,
    before         => Anchor["profile::openstack::neutron::end"],
    require        => Anchor["profile::openstack::neutron::begin"],
  }
  
  anchor { "profile::openstack::neutron::end" : }
}
