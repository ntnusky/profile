# Connects a physical interface to an openvswitch bridge
define profile::infrastructure::ovs::port::interface (
  String  $interface = $name,
  String  $bridge = "br-vlan-${name}",
  String  $driver = '',
  Integer $mtu = 1500,
) {
  require ::vswitch::ovs

  # Connects the physical interface to the bridge
  vs_port { $interface :
    ensure  => 'present',
    bridge  => $bridge,
    require => Vs_bridge[$bridge],
  }

  if($::facts['networking']['interfaces'][$interface]) {
    $mac = {
      'mac' => $::facts['networking']['interfaces'][$interface]['mac'],
    }
  } else {
    $mac = {}
  }

  # Make sure that the physical port is configured to be up.
  $os = $facts['operatingsytem']
  if($os == 'Ubuntu') {
    if($driver == '') {
      $parameters = { 'ifname' => $interface }
    } else {
      $parameters = {
        'drivername' => $driver,
        'ifname'     => $interface,
        'mtu'        => $mtu,
      }
    }

    file { "/etc/netplan/02-vswitch-${interface}.yaml":
      ensure  => file,
      mode    => '0644',
      owner   => root,
      group   => root,
      content => epp('profile/netplan/manual.epp', $parameters + $mac),
      notify  => Exec['netplan_apply'],
    }
  } elsif($os == 'CentOS') {
    $macadd = $::facts['networking']['interfaces'][$ifname]['mac']
    ::network::interface { "manual-up-${interface}":
      interface     => $interface,
      hwaddr        => $macadd,
      type          => 'OVSPort',
      devicetype    => 'ovs',
      ovs_bridge    => $bridge,
      onboot        => 'yes',
      mtu           => $mtu,
      nm_controlled => 'no',
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
