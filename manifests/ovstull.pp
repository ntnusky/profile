# Class to test some ovs issues
class profile::ovstull {
  ::profile::infrastructure::ovs::patch { "Tullogvas":
    physical_if => 'ens9',
    vlan_id     => 1337,
    ovs_bridge  => 'tullebru',
  }
}
