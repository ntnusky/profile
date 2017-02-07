# This class starts to configure sudo
class profile::baseconfig::sudo {
  class { '::sudo': }
  
  sudo::conf { 'root':
    priority => 10,
    content  => 'root  ALL=(ALL:ALL) ALL',
  }
  sudo::conf { 'admin':
    priority => 10,
    content  => '%admin ALL=(ALL) ALL',
  }
  sudo::conf { 'sudo':
    priority => 10,
    content  => '%sudo ALL=(ALL:ALL) ALL',
  }
}
