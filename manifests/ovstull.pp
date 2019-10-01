# Class to test some ovs issues
class profile::ovstull {
  require ::ntnuopenstack::repo
  require ::vswitch::ovs

  vs_bridge { 'tullebru':
    ensure => present,
  }
  vs_port { 'ens9':
    ensure => present,
    bridge => 'tullebru',
  }

  #::profile::infrastructure::ovs::patch { "Tullogvas":
  #  physical_if => 'ens9',
  #  vlan_id     => 1337,
  #  ovs_bridge  => 'tullebru',
  #}
}
