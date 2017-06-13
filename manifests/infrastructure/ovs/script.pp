# This class installs the script used by ::profile::infrastructure::ovs::patch
class profile::infrastructure::ovs::script {
  file { '/usr/local/bin/addPatch.sh':
    ensure => file
    source => 'puppet:///modules/profile/vswitch/addPatch.sh',
    mode   => '0555',
  }
}
