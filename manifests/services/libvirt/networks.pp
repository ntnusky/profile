# Configure networks for libvirt
class profile::services::libvirt::networks {
  require ::vswitch::ovs

  $networks = hiera('profile::networks', {})
  $networks.each | $network |  {
    $vlanid = hiera("profile::networks::${network}::vlanid")
    $physical_if = hiera("profile::kvm::interfaces::${network}", false)
    if ( $physical_if ) {
      vs_bridge { "br-${network}":
        ensure => present,
      }
      $n = "${network}-${vlanid}-br"
      ::profile::infrastructure::ovs::patch { $n :
        physical_if => $physical_if,
        vlan_id     => $vlanid,
        ovs_bridge  => "br-${network}",
        require     => Vs_bridge["br-${network}"],
      }
      ::libvirt::network { $network:
        ensure             => 'running',
        autostart          => true,
        forward_mode       => 'bridge',
        forward_interfaces => [ "br-${network}", ],
      }
      sysctl::value { "net.ipv6-conf.br-${network}.autoconf":
        value   => '0',
        require => Vs_bridge["br-${network}"],
      }
    }
  }
}
