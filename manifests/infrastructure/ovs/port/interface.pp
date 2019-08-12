# Connects a physical interface to an openvswitch bridge
define profile::infrastructure::ovs::port::interface (
  String $interface = $name,
  String $bridge = "br-vlan-${name}",
) {
  require ::vswitch::ovs

  vs_port { $interface :
    ensure => 'present',
    bridge => $bridge,
  }
}
