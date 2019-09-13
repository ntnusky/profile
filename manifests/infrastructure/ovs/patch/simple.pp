# This define creates a patch between two openvswitch switches.
define profile::infrastructure::ovs::patch::simple (
  String $source_bridge,
  String $destination_bridge
) {
  require ::profile::infrastructure::ovs::script::patch

  $scriptArgs = "${source_bridge} ${destination_bridge}"
  exec { "/usr/local/bin/addPatch.sh ${scriptArgs}":
    unless  => "/usr/local/bin/addPatch.sh ${scriptArgs} --verify",
    path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    require => [
      Profile::Infrastructure::Ovs::Bridge[$source_bridge],
      Profile::Infrastructure::Ovs::Bridge[$destination_bridge],
    ],
  }
}
