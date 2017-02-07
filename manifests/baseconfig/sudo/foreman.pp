# This class configures sudo for foreman
class profile::baseconfig::sudo::foreman {
  sudo::conf { 'foreman-proxy':
    ensure         => 'present',
    source         => 'puppet:///modules/profile/sudo/foreman-proxy',
    sudo_file_name => 'foreman-proxy',
  }
}
