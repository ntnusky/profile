class profile::keepalived {
  $configure_firewall 	= hiera("profile::keepalived::configure_firewall", false)
  $vrrp_password 	= hiera("profile::keepalived::vrrp_password")
  
  $management_if = hiera("profile::interface::management")
  $management_ip = getvar("::ipaddress_${management_if}")
  
  $mysql_ip = hiera("profile::mysql::ip")
  $memcache_ip = hiera("profile::memcache::ip")

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
    interface         => $management_if,
    state             => 'MASTER',
    virtual_router_id => '50',
    priority          => '100',
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "$memcache_ip/32",
      '$mysql_ip/32',
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
