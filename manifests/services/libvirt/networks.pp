# Configure networks for libvirt
class profile::services::libvirt::networks {
  require ::vswitch::ovs

  $networks = hiera('profile::networks', {})
  $networks.each | $network |  {
    # Linux interfaces is max 16 chars long (br-<13 chars>)
    $bridge_name = $network[0,13]
    $vlanid = hiera("profile::networks::${network}::vlanid")
    $physical_if = hiera("profile::kvm::interfaces::${network}", false)
    if ( $physical_if ) {
      vs_bridge { "br-${bridge_name}":
        ensure => present,
      }
      $n = "${network}-${vlanid}-br"
      ::profile::infrastructure::ovs::patch { $n :
        physical_if => $physical_if,
        vlan_id     => $vlanid,
        ovs_bridge  => "br-${bridge_name}",
        require     => Vs_bridge["br-${bridge_name}"],
      }
      ::libvirt::network { $network:
        ensure             => 'running',
        autostart          => true,
        forward_mode       => 'bridge',
        forward_interfaces => [ "br-${bridge_name}", ],
      }
      sysctl::value { "net.ipv6.conf.br-${bridge_name}.autoconf":
        value   => '0',
        require => Vs_bridge["br-${bridge_name}"],
      }
    }
  }
}
