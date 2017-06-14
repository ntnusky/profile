# Configures sudo for cinder
class profile::openstack::cinder::sudo {
  sudo::conf { 'cinder_sudoers':
    ensure         => 'present',
    source         => 'puppet:///modules/profile/sudo/cinder_sudoers',
    sudo_file_name => 'cinder_sudoers',
  }
}
