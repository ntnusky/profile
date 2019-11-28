# Connects multiple physical interfaces to a openvswitch as a LACP bond. 
define profile::infrastructure::ovs::port::bond (
  String                       $bridge,
  Variant[Array[String], Hash] $members,
  Integer                      $mtu = 1500,
) {
  require ::profile::infrastructure::ovs::script::bond

  if($members =~ Array) {
    $ifnames = $members
    $ifdata = {}
  } else {
    $ifnames = keys($members)
    $ifdata = $members
  }

  # Use the create-vswitch-lacp.sh.sh script to create the bond, and connect it
  # to the bridge.
  $memberstring = join($ifnames, ' ')
  $args = "${name} ${memberstring}"
  exec { "/usr/local/bin/create-vswitch-lacp.sh.sh ${bridge} ${args}":
    unless  => "/usr/local/bin/verify-vswitch-lacp.sh.sh ${args}",
    path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    require => Profile::Infrastructure::Ovs::Bridge[$bridge],
  }

  # Iterate through all the member ports:
  $distro = $facts['os']['release']['major']
  $ifnames.each | $ifname | {
    # Make sure the physical port is up
    if($distro == '18.04') {
      # If a particular driver is supplied; add it.
      if($ifdata[$ifname]) {
        $match = {
          'drivername' => $ifdata[$ifname]['driver'],
          'mac'        => pick(
            $ifdata[$ifname]['mac'],
            $::facter['networking']['interfaces'][$ifname]['mac'],
          ),
        }
      } else {
        $match = {}
      }

      # Add basic parameters 
      $parameters = {
        'ifname' => $ifname,
        'mtu'    => $mtu,
      }

      # Add netplan-config for the interface
      file { "/etc/netplan/02-bondmember-${ifname}.yaml":
        ensure  => file,
        mode    => '0644',
        owner   => root,
        group   => root,
        content => epp('profile/netplan/manual.epp', $parameters + $match),
        notify  => Exec['netplan_apply'],
      }
    } elsif($distro == '16.04') {
      # Add ifupdown-config for the interface
      ::network::interface { "manual-up-${ifname}":
        interface => $ifname,
        method    => 'manual',
        mtu       => $mtu,
      }
    }

    # Add monitoring for the physical port
    munin::plugin { "if_${ifname}":
      ensure => link,
      target => 'if_',
      config => ['user root', 'env.speed 10000'],
    }
    munin::plugin { "if_err_${ifname}":
      ensure => link,
      target => 'if_err_',
      config => ['user nobody'],
    }
  }
}
