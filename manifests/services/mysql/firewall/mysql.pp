#Configures the firewall for the mysql server
class profile::services::mysql::firewall::mysql {
  ::profile::firewall::infra::region { 'MYSQL-SERVER':
    port     => 3306,
  }
}
