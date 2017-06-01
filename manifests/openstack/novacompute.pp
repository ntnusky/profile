# This class installs and configures nova for a compute-node.
class profile::openstack::novacompute {
  $nova_public_api = hiera('profile::api::nova::public::ip')
  $nova_libvirt_type = hiera('profile::nova::libvirt_type')
  $nova_libvirt_model = hiera('profile::nova::libvirt_model')
  $nova_key = hiera('profile::ceph::nova_key')
  $nova_uuid = hiera('profile::ceph::nova_uuid')

  $controller_management_addresses = hiera('controller::management::addresses')
  $memcache_ip = hiera('profile::memcache::ip')

  $mysql_password = hiera('profile::mysql::novapass')
  $keystone_ip = hiera('profile::api::keystone::admin::ip')
  $mysql_ip = hiera('profile::mysql::ip')

  $region = hiera('profile::region')
  $neutron_ip = hiera('profile::api::neutron::admin::ip')
  $nova_password = hiera('profile::nova::keystone::password')
  $neutron_password = hiera('profile::neutron::keystone::password')

  $management_if = hiera('profile::interfaces::management')
  $management_ip = getvar("::ipaddress_${management_if}")

  $rabbit_user = hiera('profile::rabbitmq::rabbituser')
  $rabbit_pass = hiera('profile::rabbitmq::rabbitpass')
  $rabbit_ip = hiera('profile::rabbitmq::ip')

  $database_connection = "mysql://nova:${mysql_password}@${mysql_ip}/nova"

  require ::profile::openstack::repo
  include ::profile::munin::plugin::compute

  class { '::nova':
    database_connection => $database_connection,
    glance_api_servers  =>
      join([join($controller_management_addresses, ':9292,'),''], ':9292'),
    rabbit_host         => $rabbit_ip,
    rabbit_userid       => $rabbit_user,
    rabbit_password     => $rabbit_pass,
  }

  exec { '/usr/bin/ceph osd pool create volumes 512' :
    unless  => '/usr/bin/ceph osd pool get volumes size',
    require => Anchor['profile::ceph::client::end'],
  }

  nova_config { 'DEFAULT/default_floating_pool': value => 'public' }

  class { '::nova::network::neutron':
    neutron_password      => $neutron_password,
    neutron_region_name   => $region,
    neutron_auth_url      => "http://${keystone_ip}:35357/v3",
    neutron_url           => "http://${neutron_ip}:9696",
    vif_plugging_is_fatal => false,
    vif_plugging_timeout  => '0',
  }

  class { '::nova::compute':
    enabled                       => true,
    vnc_enabled                   => true,
    vncserver_proxyclient_address => $management_ip,
    vncproxy_host                 => $nova_public_api
  }

  ceph_config {
    'client.nova/key':              value => $nova_key;
  }

  user { 'nova':
    shell       => '/bin/bash',
  }

  class { '::nova::compute::libvirt':
    libvirt_virt_type => $nova_libvirt_type,
    vncserver_listen  => $management_ip,
    libvirt_cpu_mode  => 'custom',
    libvirt_cpu_model => $nova_libvirt_model,
  }

  class { '::nova::compute::rbd':
    libvirt_rbd_user        => 'nova',
    libvirt_images_rbd_pool => 'volumes',
    libvirt_rbd_secret_uuid => $nova_uuid,
    require                 => Ceph::Key['client.nova'],
    manage_ceph_client      => false,
  }

  class { '::nova::migration::libvirt':
    live_migration_flag  =>
      'VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE',
    block_migration_flag =>
      'VIR_MIGRATE_UNDEFINE_SOURCE, VIR_MIGRATE_PEER2PEER, VIR_MIGRATE_LIVE, VIR_MIGRATE_NON_SHARED_INC',
  }

  ceph::key { 'client.nova':
    secret  => $nova_key,
    cap_mon => 'allow r',
    cap_osd => 'allow class-read object_prefix rbd_children,allow rwx pool=volumes, allow rwx pool=images',
    inject  => true,
  }

  file { '/etc/libvirt/qemu.conf':
    ensure => present,
    source => 'puppet:///modules/profile/qemu.conf',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Service['libvirt'],
  }

  sudo::conf { 'nova_sudoers':
    ensure         => 'present',
    source         => 'puppet:///modules/profile/sudo/nova_sudoers',
    sudo_file_name => 'nova_sudoers',
  }

  Package['libvirt'] -> File['/etc/libvirt/qemu.conf']
}

