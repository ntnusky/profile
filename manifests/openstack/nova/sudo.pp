# Configures sudo for the nova service.
class profile::openstack::nova::sudo {
  sudo::conf { 'nova_sudoers':
    ensure         => 'present',
    source         => 'puppet:///modules/profile/sudo/nova_sudoers',
    sudo_file_name => 'nova_sudoers',
  }
}
