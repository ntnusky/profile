define profile::infrastructure::ovs::port::single (
  String $interface = $name,
  String $bridgename = "br-vlan-${name}",
) {
  require ::vswitch::ovs

  vs_port { $interface :
    ensure => 'present',
    bridge => $bridgename,
  }
}
