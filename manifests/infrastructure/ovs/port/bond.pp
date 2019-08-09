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

  $distro = $facts['os']['release']['major']
  $members.each | $member | {
    if($distro == '18.04') {
      file { "/etc/netplan/02-bondmember-${member}.yaml":
        ensue   => file,
        mode    => '0644',
        owner   => root,
        group   => root,
        content => epp('profile/netplan/manual.epp', {
          'ifname' => $member,
        }),
        notify  => Exec['netplan_apply'],
        require => Class['::netplan'],
      }
    } elsif($distro == '16.04') {
      ::network::interface { "manual-up-${member}":
        interface => $member,
        method    => $manual,
      }
    }
  }
}
