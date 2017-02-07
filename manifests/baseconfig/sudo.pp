# This class starts to configure sudo
class profile::baseconfig::sudo {
  class { '::sudo': }
  
  sudo::conf { 'insult':
    priority => 10,
    content  => 'Defaults	insult',
  }
}
