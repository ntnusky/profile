# This class configures the zabbix database
class profile::zabbix::database {
  $db_pass = lookup('profile::zabbix::database::password', String)

  include ::profile::zabbix::deps

  class { 'zabbix::database':
    database_type     => 'mysql',
    database_password => $db_pass,
    before            => Anchor['shiftleader::database::create'],
  }
}
