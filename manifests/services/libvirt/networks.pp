# Configure networks for libvirt. Connects libvirt networks to openvswitch
# switches according to hiera: 
#
# profile::kvm::networks:
#   <networkname>:
#     bridge: '<vswitch-bridge>'
#   <networkname>:
#     bridge: '<vswitch-bridge>'
#     vlan: <vlanID>
#
class profile::services::libvirt::networks {
  require ::vswitch::ovs

  # The proposed way of configuring networks
  $kvm_networks = lookup('profile::kvm::networks', {
    'default_value' => {},
    'merge'         => 'deep',
    'value_type'    => Hash[String, Hash],
  })

  $kvm_networks.each | String $netname, Hash $data | {
    $shortname = $netname[0,12]
    $bridge = $data['bridge']

    profile::infrastructure::ovs::bridge { "br-${shortname}": }

    if('vlanid' in $data) {
      profile::infrastructure::ovs::patch::vlan { 
          "patch br-${shortname} to ${bridge}":
        source_bridge      => $bridge,
        source_vlan        => $data['vlanid'],
        destination_bridge => "br-${shortname}",
      }
    } else {
      profile::infrastructure::ovs::patch::simple { 
          "patch br-${shortname} to ${bridge}":
        source_bridge      => $bridge,
        destination_bridge => "br-${shortname}",
      }
    }

    ::libvirt::network { $network:
      ensure                => 'running',
      autostart             => true,
      forward_mode          => 'bridge',
      forward_interfaces    => [ "br-${shortname}", ],
      trust_guest_rxfilters => true, 
    }
    sysctl::value { "net.ipv6.conf.br-${shortname}.autoconf":
      value   => '0',
      require => Profile::Infrastructure::Ovs::Bridge["br-${shortname}"],
    }
  }
}
