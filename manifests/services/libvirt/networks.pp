# Configure networks for libvirt
class profile::services::libvirt::networks {
  require ::vswitch::ovs

  $networks = hiera('profile::networks', {})
  $networks.each | $network |  {
    $vlanid = hiera("profile::networks::${network}::vlanid")
    $physical_if = hiera("profile::kvm::interfaces::${network}", false)
    if ( $physical_if ) {
      vs_bridge { "br-vlan-${network}":
        ensure => present,
      }
      $n = "${network}-${vlanid}-br"
      ::profile::infrastructure::ovs::patch { $n :
        physical_if => $physical_if,
        vlan_id     => $vlanid,
        ovs_bridge  => "br-vlan-${network}",
        require     => Vs_bridge["br-vlan-${network}"],
      }
      ::libvirt::network { $network:
        ensure             => 'running',
        autostart          => true,
        forward_mode       => 'bridge',
        forward_interfaces => [ "br-vlan-${network}", ],
      }
    }
  }
}
