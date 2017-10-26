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
    mdns_adv          => false,
    networks          => $networks,
    networks_defaults => $net_defaults,
  }
}
