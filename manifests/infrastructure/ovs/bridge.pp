define profile::infrastructure::ovs::bridge {
  require ::vswitch::ovs

  vs_bridge { $name:
    ensure => 'present',
  }
}
