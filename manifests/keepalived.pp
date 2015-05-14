class profile::keepalived {
  $configure_firewall 	= hiera("profile::keepalived::configure_firewall", false)
  $vrrp_password 	= hiera("profile::keepalived::vrrp_password")
  
  # Let VRRP packets trough the firewall of the management interface.
  if($configure_firewall == true) {
    firewall { '0003 - Accept VRRP':
      action => 'accept',
      proto  => 'vrrp',
      before => [ Firewall['8999 - Accept all management network traffic'] ],
    }
  }
  
  anchor { "profile::keepalived::begin" : }
  anchor { "profile::keepalived::end" : }
  
  # Enable bindings to ip's not present on the machine, so that the
  # services can bind to keepalived addresses.
  sysctl::value { 'net.ipv4.ip_nonlocal_bind':
    value => "1",
    before              => Anchor['profile::keepalived::end'],
    require             => Anchor['profile::keepalived::begin'],
  }

  include ::keepalived
  
  keepalived::vrrp::script { 'check_mysql':
    script => '/usr/bin/killall -0 mysqld',
    before              => Anchor['profile::keepalived::end'],
    require             => Anchor['profile::keepalived::begin'],
  }
  
  # Define the virtual addresses
  keepalived::vrrp::instance { 'management-database':
    interface         => 'eth1',
    state             => 'MASTER',
    virtual_router_id => '50',
    priority          => '100',
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      '172.16.2.9/32',	# Memcache IP
      '172.16.2.10/32', # Mysql IP
    ],
    track_script      => 'check_mysql',
    before              => Anchor['profile::keepalived::end'],
    require             => Anchor['profile::keepalived::begin'],
  }
  #keepalived::vrrp::instance { 'public-network':
  #  interface         => 'eth0',
  #  state             => 'MASTER',
  #  virtual_router_id => '50',
  #  priority          => '100',
  #  auth_type         => 'PASS',
  #  auth_pass         => 'oXu7ahca',
  #  virtual_ipaddress => [
  #    '172.16.1.5/32',	# Public API IP
  #  ],
  #  track_script      => 'check_haproxy',
  #}
}
