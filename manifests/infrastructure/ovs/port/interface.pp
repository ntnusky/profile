# Connects a physical interface to an openvswitch bridge
define profile::infrastructure::ovs::port::interface (
  String $interface = $name,
  String $bridge = "br-vlan-${name}",
) {
  require ::vswitch::ovs

  notify { "IF: ${interface}" : }
  notify { "BR: ${bridge}" : }

  vs_port { $interface :
    ensure  => 'present',
    bridge  => $bridge,
    require => Vs_bridge[$bridge],
  }

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
}
