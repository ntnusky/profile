class profile::openstack::neutronnetworks {
  $public_net = hiera("profile::networks::public")
  
  anchor { "profile::openstack::neutronnetworks::begin" :
    require => Anchor["profile::openstack::neutron::begin"],
  }
  
  anchor { "profile::openstack::neutronnetworks::end" : }

  neutron_network { 'public':
    ensure          => present,
    router_external => 'True',
    tenant_name     => 'admin',
  }

  neutron_subnet { 'public_subnet':
    ensure       => 'present',
    cidr         => $public_net,
    network_name => 'public',
    tenant_name  => 'admin',
  }
  
  neutron_network { 'MiscNet':
    ensure      => present,
    tenant_name => 'admin',
  }
  
  neutron_subnet { 'MiscNet_subnet':
    ensure       => present,
    cidr         => '10.1.0.0/20',
    network_name => 'MiscNet',
    tenant_name  => 'admin',
  }
  
  # Tenant-private router - assumes network namespace isolation
  neutron_router { 'misc_router':
    ensure               => present,
    tenant_name          => 'admin',
    gateway_network_name => 'public',
    require              => Neutron_subnet['MiscNet_subnet'],
  }
  
  neutron_router_interface { 'misc_router:MiscNet_subnet':
    ensure => present,
  }
}
