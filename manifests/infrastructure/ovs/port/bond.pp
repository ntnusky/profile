# Connects multiple physical interfaces to a openvswitch as a LACP bond. 
define profile::infrastructure::ovs::port::bond (
  String        $bridge,
  Array[String] $members,
) {
  require ::profile::infrastructure::ovs::script::bond

  $memberstring = join($members, ' ')
  $args = "${name} ${memberstring}"

  exec { "/usr/local/bin/create-vswitch-lacp.sh.sh ${bridge} ${args}":
    unless  => "/usr/local/bin/verify-vswitch-lacp.sh.sh ${args}",
    path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    require => Profile::Infrastructure::Ovs::Bridge[$bridge],
  }
}
