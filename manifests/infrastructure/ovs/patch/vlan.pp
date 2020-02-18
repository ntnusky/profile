# This define creates a patch between two openvswitch switches. On the
# source_bridge the patch can connect to a port in a certain VLAN, while the
# destination is allways in the default-VLAN.
define profile::infrastructure::ovs::patch::vlan (
  String $source_bridge,
  Integer $source_vlan,
  String $destination_bridge
) {
  require ::profile::infrastructure::ovs::script::patch

  $scriptArgs = "${source_bridge} ${destination_bridge} ${source_vlan}"
  exec { "/usr/local/bin/addPatch.sh ${scriptArgs}":
    unless  => "/usr/local/bin/addPatch.sh ${scriptArgs} --verify",
    path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    require => [
      Profile::Infrastructure::Ovs::Bridge[$source_bridge],
      Profile::Infrastructure::Ovs::Bridge[$destination_bridge],
    ],
  }
}
