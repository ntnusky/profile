# Configures the database used for the munin::vgpu plugins.
class profile::monitoring::munin::plugin::vgpu::db {
  $database_name = lookup('profile::munin::vgpu::database::name', {
    'value_type'    => String,
    'default_value' => 'munin-vgpu',
  })
  $database_grant = lookup('profile::munin::vgpu::database::grant', {
    'value_type'    => String,
    'default_value' => '%',
  })
  $database_user = lookup('profile::munin::vgpu::database::user', {
    'value_type'    => String,
    'default_value' => 'munin-vgpu',
  })
  $database_pass = lookup('profile::munin::vgpu::database::pass', {
    'value_type'    => Variant[String, Boolean],
    'default_value' => false,
  })

  if($database_pass) {
    mysql_database { $database_name:
      ensure  => present,
      charset => 'utf8',
      collate => 'utf8_general_ci',
      require => [ Class['::mysql::server'] ],
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
}
