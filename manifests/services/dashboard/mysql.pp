# Configures the dashboard.
class profile::services::dashboard::mysql {
  $configfile = hiera('profile::dashboard::configfile',
      '/etc/machineadmin/settings.ini')
  $database_name = hiera('profile::dashboard::database::name')
  $database_grant = hiera('profile::dashboard::database::grant')
  $database_user = hiera('profile::dashboard::database::user')
  $database_pass = hiera('profile::dashboard::database::pass')

  mysql_database { $database_name:
    ensure  => present,
    charset => 'utf8',
    collate => 'utf8_general_ci',
    require => [ Class['::profile::mysql::cluster'] ],
  }

  mysql_user { "${database_user}@${database_grant}":
    password_hash => mysql_password($database_pass),
    require       => Mysql_database[$database_name],
  }

  mysql_grant { "${database_user}@${database_grant}/${database_name}.*":
    privileges => ['ALL'],
    table      => "${database_name}.*",
    require    => Mysql_user["${database_user}@${database_grant}"],
    user       => "${database_user}@${database_grant}",
  }
}
