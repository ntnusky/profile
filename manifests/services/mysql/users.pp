# Configuring galera and maraidb cluster
class profile::services::mysql::users {
  $standalonepw = lookup('profile::mysql::root_password', {
    'default_value' => undef,
    'value_type'    => Optional[String],
  }) 
  $rootpassword = lookup('profile::mysqlcluster::root_password', {
    'default_value' => $standalonepw,
    'value_type'    => String, 
  })

  $haproxypassword = lookup('profile::mysqlcluster::haproxy_password', {
    'default_value' => undef,
    'value_type'    => Optional[String],
  })

  $zabbix_servers = lookup('profile::zabbix::agent::servers', {
    'default_value' => [],
    'value_type'    => Array[Stdlib::IP::Address::Nosubnet],
  })

  if($zabbix_servers =~ Array[Stdlib::IP::Address::Nosubnet, 1]) {
    include ::profile::services::mysql::users::zabbixagent
  }

  file { '/root/.my.cnf':
    ensure  => 'file',
    owner   => root,
    group   => root,
    mode    => '0600',
    content => epp('profile/mysql/root.my.cnf.epp', {
      'password' => $rootpassword
    }),
    require => Service['mysqld'],
    before  => Class['mysql::server::root_password'],
  }

  mysql_user { 'root@%':
    ensure        => 'present',
    password_hash => mysql::password($rootpassword)
  }
  ->mysql_grant { 'root@%/*.*':
    ensure     => 'present',
    options    => ['GRANT'],
    privileges => ['ALL'],
    table      => '*.*',
    user       => 'root@%',
  }

  if($haproxypassword) {
    mysql_user { 'haproxy_check@%':
      ensure        => 'present',
      password_hash => mysql::password($haproxypassword)
    }
    ->mysql_grant { 'haproxy_check@%/mysql.user':
      ensure     => 'present',
      options    => ['GRANT'],
      privileges => ['SELECT'],
      table      => 'mysql.user',
      user       => 'haproxy_check@%',
    }
  } else {
    mysql_user { 'haproxy_check@%':
      ensure => 'absent',
    }
  }
}
