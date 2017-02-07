# This class starts to configure sudo
class profile::baseconfig::sudo {
  class { '::sudo': }
  
  sudo::conf { 'insults':
    priority => 10,
    content  => 'Defaults	insults',
  }
}
