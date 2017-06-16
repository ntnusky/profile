# This class creates an openvswitch bridge which terminates a physical interface
# which is connected to a trunk port of a physical switch. Other virtual
# switches might patch in to this bridge.
define profile::infrastructure::ovs::bridge {
  require ::vswitch::ovs

  vs_bridge { "br-vlan-${name}":
    ensure => 'present',
  }

  vs_port { $name :
    ensure => 'present',
    bridge => "br-vlan-${name}",
  }
}
