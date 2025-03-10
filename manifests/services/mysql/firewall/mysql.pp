#Configures the firewall for the mysql server
class profile::services::mysql::firewall::mysql {
  $common = lookup('profile::mysql::interregional', {
    'default_value' => false,
    'value_type'    => Boolean,
  })

  if($common) {
    ::profile::firewall::infra::all { 'MYSQL-SERVER':
      port     => 3306,
    }
  } else {
    ::profile::firewall::infra::region { 'MYSQL-SERVER':
      port     => 3306,
    }
  }
}
