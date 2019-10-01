# Class to test some ovs issues
class profile::ovstull {
  require ::ntnuopenstack::repo

  vs_bridge { 'tullebru':
    ensure => present,
  }
  vs_interface { 'ens9':
    ensure => present,
    bridge => 'tullebru',
  }

  #::profile::infrastructure::ovs::patch { "Tullogvas":
  #  physical_if => 'ens9',
  #  vlan_id     => 1337,
  #  ovs_bridge  => 'tullebru',
  #}
}
