# Connects a physical interface to an openvswitch bridge
define profile::infrastructure::ovs::port::interface (
  String $interface = $name,
  String $bridge = "br-vlan-${name}",
) {
  require ::vswitch::ovs

  # Connects the physical interface to the bridge
  vs_port { $interface :
    ensure  => 'present',
    bridge  => $bridge,
    require => Vs_bridge[$bridge],
  }

  # Make sure that the physical port is configured to be up.
  $distro = $facts['os']['release']['major']
  if($distro == '18.04') {
    file { "/etc/netplan/02-vswitch-${interface}.yaml":
      ensure  => file,
      mode    => '0644',
      owner   => root,
      group   => root,
      content => epp('profile/netplan/manual.epp', {
        'ifname' => $interface,
      }),
      notify  => Exec['netplan_apply'],
    }
  } elsif($distro == '16.04') {
    ::network::interface { "manual-up-${interface}":
      interface => $interface,
      method    => 'manual',
    }
  }

  # Add monitoring for the physical port
  munin::plugin { "if_${interface}":
    ensure => link,
    target => 'if_',
    config => ['user root', 'env.speed 10000'],
  }
  munin::plugin { "if_err_${interface}":
    ensure => link,
    target => 'if_err_',
    config => ['user nobody'],
  }
}
