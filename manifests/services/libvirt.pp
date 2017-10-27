# Configure libvirt hosts
class profile::services::libvirt {

  #$mgmt_nic = hiera('profile::interfaces::management')

  #  $networks = {
  #  'mgmt-net' => {
  #    autostart          => true,
  #    forward_mode       => 'bridge',
  #    forward_interfaces => [ $mgmt_nic, ],
  #  }
  #}

  $networks = hiera('profile::libvirt::networks'), [])

  $net_defaults = {
    'ensure'    => present,
    'autostart' => true,
  }

  contain ::profile::services::libvirt::pools

  class { '::libvirt':
    deb_default       => {
      'libvirtd_opts' => '',
    },
    mdns_adv          => false,
    networks          => $networks,
    networks_defaults => $net_defaults,
  }

  package { 'vlan':
    ensure => present,
  }
}
