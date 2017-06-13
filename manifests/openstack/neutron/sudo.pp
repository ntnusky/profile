# Configures sudo for neutron
class profile::openstack::neutron::sudo {
  sudo::conf { 'neutron_sudoers':
    ensure         => 'present',
    source         => 'puppet:///modules/profile/sudo/neutron_sudoers',
    sudo_file_name => 'neutron_sudoers',
  }
}
