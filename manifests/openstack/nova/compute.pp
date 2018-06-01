# This class installs and configures nova for a compute-node.
class profile::openstack::nova::compute {
  # Determine the VNCProxy-settings
  $nova_public = hiera('profile::api::nova::public::ip', '127.0.0.1')
  $host = hiera('profile::horizon::server_name', undef)
  $vncproxy_host = pick($host, $nova_public)
  $port = hiera('profile::vncproxy::port', 6080)
  $cert = hiera('profile::haproxy::services::apicert', false)

  $management_if = hiera('profile::interfaces::management')
  $management_ip = getvar("::ipaddress_${management_if}")
  $nova_uuid = hiera('profile::ceph::nova_uuid')

  require ::profile::openstack::repo
  require ::profile::openstack::nova::base::compute
  contain ::profile::openstack::nova::ceph
  contain ::profile::openstack::nova::neutron
  contain ::profile::openstack::nova::libvirt
  include ::profile::openstack::nova::firewall::compute
  include ::profile::openstack::nova::munin::compute

  if($cert) {
    $protocol = 'https'
  } else {
    $protocol = 'http'
  }

  nova_config { 'DEFAULT/default_floating_pool': value => 'public' }

  class { '::nova::compute':
    enabled                          => true,
    vnc_enabled                      => true,
    vncserver_proxyclient_address    => $management_ip,
    vncproxy_host                    => $vncproxy_host,
    vncproxy_protocol                => $protocol,
    vncproxy_port                    => $port,
    resume_guests_state_on_host_boot => true,
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

