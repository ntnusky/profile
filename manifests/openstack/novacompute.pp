class profile::openstack::novacompute {
  $nova_public_api = hiera("profile::api::nova::public::ip")
  $nova_libvirt_type = hiera("profile::nova::libvirt_type")
  $nova_key = hiera("profile::ceph::nova_key")
  
  $controller_management_addresses = hiera("controller::management::addresses")
  $memcache_ip = hiera("profile::memcache::ip")

  $mysql_password = hiera("profile::mysql::novapass")
  $keystone_ip = hiera("profile::api::keystone::public::ip")
  $mysql_ip = hiera("profile::mysql::ip")

  $region = hiera("profile::region")
  $neutron_ip = hiera("profile::api::neutron::admin::ip")
  $nova_password = hiera("profile::nova::keystone::password")
  $neutron_password = hiera("profile::neutron::keystone::password")
  
  $rabbit_user = hiera("profile::rabbitmq::rabbituser")
  $rabbit_pass = hiera("profile::rabbitmq::rabbitpass")

  $database_connection = "mysql://nova:${mysql_password}@${mysql_ip}/nova"
  
  include ::profile::openstack::repo

  class { '::nova':
    database_connection => $database_connection,
    glance_api_servers  => join($controller_management_addresses, ','),
    memcached_servers   => ["${memcache_ip}:11211"],
    rabbit_hosts        => $controller_management_addresses,
    rabbit_userid       => $rabbit_user,
    rabbit_password     => $rabbit_pass,
    mysql_module        => '2.2',
  }

  exec { "/usr/bin/ceph osd pool create vms 2048" :
    unless => "/usr/bin/ceph osd pool get vms size",
  }

  nova_config { 'DEFAULT/default_floating_pool': value => 'public' }

  class { '::nova::network::neutron':
    neutron_admin_password => $neutron_password,
    neutron_region_name    => $region,
    neutron_admin_auth_url => "http://${keystone_ip}:35357/v2.0",
    neutron_url            => "http://${neutron_ip}:9696",
    vif_plugging_is_fatal  => false,
    vif_plugging_timeout   => '0',
  }
  
  class { '::nova::compute':
    enabled                       => true,
    vnc_enabled                   => true,
    vncserver_proxyclient_address => $::ipaddress_eth1,
    vncproxy_host                 => $nova_public_api
  }

  ceph_config {
      'client.nova/key':              value => $nova_key;
  }

  class { '::nova::compute::libvirt':
    libvirt_virt_type => $nova_libvirt_type,
    vncserver_listen  => $::ipaddress_eth1,
  }

  class { '::nova::compute::rbd':
    libvirt_rbd_user    => 'nova',
    libvirt_images_rbd_pool => 'images',
    before              => Ceph::Key['client.nova'],
  }

  class { '::nova::migration::libvirt':
  }

  ceph::key { 'client.nova':
    secret        => $nova_key,
    cap_mon       => 'allow r',
    cap_osd       => 'allow class-read object_prefix rbd_children, allow rwx pool=images',
  }

  file { '/etc/libvirt/qemu.conf':
    ensure => present,
    source => 'puppet:///modules/profile/qemu.conf',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Service['libvirt'],
  }

  Package['libvirt'] -> File['/etc/libvirt/qemu.conf']
}

