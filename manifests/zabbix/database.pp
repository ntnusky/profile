# This class configures the zabbix database
class profile::zabbix::database {
  $db_pass = lookup('profile::zabbix::database::password', String)

  class { 'zabbix::database':
    database_type     => 'mysql',
    database_password => $db_pass,
  }
}
