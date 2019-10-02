# This class creates an ::profile::infrastructure::ovs::bridge if it does not
# exist. If the bridge is created, it is also connected to a physical interface.
# 
# When the bridge exists it creates a patch interface between a tagged access 
# port of this bridge and the $ovs_bridge.
#
# It is in practice used to connect an OVS bridge to a VLAN on a physical trunk.
#
# TODO: This class should be removed, and replaced with more generic classes.
#       This is scheduled to a later time as the ntnuopenstack module currently
#       uses this class.
define profile::infrastructure::ovs::patch (
  $physical_if,
  $vlan_id,
  $ovs_bridge,
) {
  #require ::profile::infrastructure::ovs::script::patch

  # Make sure there is a bridge connected to the physical interface.
  if ! defined(Profile::Infrastructure::Ovs::Bridge["br-vlan-${physical_if}"]) {
    ::profile::infrastructure::ovs::bridge { "br-vlan-${physical_if}" : }
  }
  if ! defined(Profile::Infrastructure::Ovs::Port::Interface[$physical_if]) {
    ::profile::infrastructure::ovs::port::interface { $physical_if: }
  }

  # Connect a patch between the supplied bridge and the bridge connected to the
  # physical interface.
  #$scriptArgs = "br-vlan-${physical_if} ${ovs_bridge} ${vlan_id}"
  #exec { "/usr/local/bin/addPatch.sh ${scriptArgs}":
  #  unless  => "/usr/local/bin/addPatch.sh ${scriptArgs} --verify",
  #  path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  #  require => Profile::Infrastructure::Ovs::Bridge["br-vlan-${physical_if}"],
  #}
}
