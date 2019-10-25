# Connects multiple physical interfaces to a openvswitch as a LACP bond. 
define profile::infrastructure::ovs::port::bond (
  String        $bridge,
  Array[String] $members,
) {
  require ::profile::infrastructure::ovs::script::bond

  # Use the create-vswitch-lacp.sh.sh script to create the bond, and connect it
  # to the bridge.
  $memberstring = join($members, ' ')
  $args = "${name} ${memberstring}"
  exec { "/usr/local/bin/create-vswitch-lacp.sh.sh ${bridge} ${args}":
    unless  => "/usr/local/bin/verify-vswitch-lacp.sh.sh ${args}",
    path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    require => Profile::Infrastructure::Ovs::Bridge[$bridge],
  }

  # Iterate through all the member ports:
  $distro = $facts['os']['release']['major']
  $members.each | $member | {
    # Make sure the physical port is up
    if($distro == '18.04') {
      file { "/etc/netplan/02-bondmember-${member}.yaml":
        ensure  => file,
        mode    => '0644',
        owner   => root,
        group   => root,
        content => epp('profile/netplan/manual.epp', {
          'ifname' => $member,
        }),
        notify  => Exec['netplan_apply'],
      }
    } elsif($distro == '16.04') {
      ::network::interface { "manual-up-${member}":
        interface => $member,
        method    => 'manual',
      }
    }

    # Add monitoring for the physical port
    munin::plugin { "if_${member}":
      ensure => link,
      target => 'if_',
      config => ['user root', 'env.speed 10000'],
    }
    munin::plugin { "if_err_${member}":
      ensure => link,
      target => 'if_err_',
      config => ['user nobody'],
    }
  }
}
