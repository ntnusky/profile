# Installs the scripts configuring a bond connected to an openvswitch-switch.
class profile::infrastructure::ovs::script::bond {
  file { '/usr/local/bin/create-vswitch-lacp.sh.sh':
    ensure => file,
    source => 'puppet:///modules/profile/vswitch/create-vswitch-lacp.sh',
    mode   => '0555',
  }
  file { '/usr/local/bin/verify-vswitch-lacp.sh.sh':
    ensure => file,
    source => 'puppet:///modules/profile/vswitch/verify-vswitch-lacp.sh',
    mode   => '0555',
  }
}
