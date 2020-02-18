# sudo config for mysql
class profile::services::mysql::sudo {
  sudo::conf { 'mysql':
    priority => 50,
    source   => 'puppet:///modules/profile/sudo/mysql_sudoers',
  }
}
