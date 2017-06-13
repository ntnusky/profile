# Configures neutron to connect to the external networks defined in the hiera
# files.
class profile::openstack::neutron::external {
  $external_networks = hiera_array('profile::neutron::external::networks', [])

  require ::vswitch::ovs

  $external = $external_networks.each |$net| {
    $vlanid = hiera("profile::neutron::external::${net}::vlanid")
    $bridge = hiera("profile::neutron::external::${net}::bridge")
    $interface = hiera("profile::neutron::external::${net}::interface")

    if($vlanid == 0) {
      vs_port { $interface:
        ensure => present,
        bridge => $bridge,
      }
    } else {
      $n = "${interface}-${vlanid}-${bridge}"
      ::profile::infrastructure::ovs::patch { $n :
        physical_if => $interface,
        vlan_id     => $vlanid,
        ovs_bridge  => $bridge,
      }
    }
  }
}
