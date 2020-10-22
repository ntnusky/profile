#Configures the firewall for the mysql server
class profile::services::mysql::firewall::mysql {
  ::profile::baseconfig::firewall::service::infra { 'MYSQL-SERVER':
    protocol => 'tcp',
    port     => 3306,
  }
}
