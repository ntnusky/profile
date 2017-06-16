# This class configures sudo for glance
class profile::openstack::glance::sudo {
  sudo::conf { 'glance_sudoers':
    ensure         => 'present',
    source         => 'puppet:///modules/profile/sudo/glance_sudoers',
    sudo_file_name => 'glance_sudoers',
  }
}
