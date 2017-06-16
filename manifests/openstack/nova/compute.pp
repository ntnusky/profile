# This class installs and configures nova for a compute-node.
class profile::openstack::nova::compute {
  $nova_public_api = hiera('profile::api::nova::public::ip')
  $management_if = hiera('profile::interfaces::management')
  $management_ip = getvar("::ipaddress_${management_if}")
  $nova_uuid = hiera('profile::ceph::nova_uuid')

  require ::profile::openstack::repo
  require ::profile::openstack::nova::base::compute
  contain ::profile::openstack::nova::ceph
  contain ::profile::openstack::nova::neutron
  contain ::profile::openstack::nova::libvirt
  include ::profile::openstack::nova::munin::compute

  nova_config { 'DEFAULT/default_floating_pool': value => 'public' }

  class { '::nova::compute':
    enabled                       => true,
    vnc_enabled                   => true,
    vncserver_proxyclient_address => $management_ip,
    vncproxy_host                 => $nova_public_api
  }

  user { 'nova':
    shell => '/bin/bash',
  }

  class { '::nova::compute::rbd':
    libvirt_rbd_user        => 'nova',
    libvirt_images_rbd_pool => 'volumes',
    libvirt_rbd_secret_uuid => $nova_uuid,
    manage_ceph_client      => false,
  }
}

