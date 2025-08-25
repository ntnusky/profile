# Configures sudo to let zabbix run some scripts as root. 
class profile::zabbix::agent::sudo {
  sudo::conf { 'zabbix_agent':
    priority => 15,
    source   => 'puppet:///modules/profile/zabbix/sudoers',
  }
}
