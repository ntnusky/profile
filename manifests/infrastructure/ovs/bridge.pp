# Create an openvswitch bridge
define profile::infrastructure::ovs::bridge (
  Variant[Integer, Undef] $mtu = undef,
) {
  require ::vswitch::ovs

  vs_bridge { $name:
    ensure => 'present',
  }

  if($mtu) {
    $getcmd = "/usr/bin/ovs-vsctl get interface ${name} mtu_request"
    exec { "/usr/bin/ovs-vsctl set interface ${name} mtu_request=${mtu}":
      unless  => "[ \$(${getcmd}) -eq ${mtu} ]",
      require => Vs_bridge[$name],
    }
  }
}
