# Class to test some ovs issues
class profile::ovstull {
  require ::ntnuopenstack::repo
  require ::vswitch::ovs

  vs_port { 'ens9':
    ensure => present,
    bridge => 'br-vlan-ens9',
    require => Vs_bridge['br-vlan-ens9'],
  }

  profile::infrastructure::ovs::bridge { 'tullebru' : }
  profile::infrastructure::ovs::bridge { 'br-vlan-ens9' : }

  #::profile::infrastructure::ovs::patch { "Tullogvas":
  #  physical_if => 'ens9',
  #  vlan_id     => 1337,
  #  ovs_bridge  => 'tullebru',
  #}
}
