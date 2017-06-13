# This class creates an ::profile::infrastructure::ovs::bridge if it does not
# exist before it creates a patch interface between a tagged access port of this
# bridge and the $target_bridge.
#
# It is in practice used to connect an OVS bridge to a VLAN on a physical trunk.
define profile::infrastructure::ovs::patch (
  $physical_if,
  $vlan_id,
  $ovs_bridge,
) {
  require ::profile::infrastructure::ovs::script

  # Make sure there is a bridge connected to the physical interface.
  if ! defined(Profile::Infrastructure::Ovs::Bridge[$physical_if]) {
    ::profile::infrastructure::ovs::bridge { $physical_if : }
  }

  # Connect a patch between the supplied bridge and the bridge connected to the
  # physical interface.
  $scriptArgs = "${physical_if} ${ovs_bridge} ${vlan_id}"
  exec { "/usr/local/bin/addPatch.sh ${scriptArgs}":
    unless  => "/usr/local/bin/addPatch.sh ${scriptArgs} --verify",
    path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    require => Profile::Infrastructure::Vlanbridge[$physical_if],
  }
}
