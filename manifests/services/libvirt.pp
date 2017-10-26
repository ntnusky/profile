# Configure libvirt hosts
class profile::services::libvirt {

  $mgmt_nic = hiera('profile::interfaces::management')

  $networks = {
    'mgmt-net' => {
      autostart          => true,
      forward_mode       => 'bridge',
      forward_interfaces => [ $mgmt_nic, ],
    }
  }

  $net_defaults = {
    'ensure'    => present,
    'autostart' => true,
  }

  class { '::libvirt':
    deb_defaults      => {
      'libvirtd_opts' => '',
    },
    mdns_adv          => false,
    networks          => $networks,
    networks_defaults => $net_defaults,
  }

  libvirt_pool { 'vmvg':
    ensure    => present,
    type      => 'logical',
    autostart => true,
    target    => '/dev/vmvg',
  }

  libvirt_pool { 'default':
    ensure => absent,
  }
}
