# Configuring galera and maraidb cluster
class profile::services::mysql::users {
  $master  = hiera('profile::mysqlcluster::master')
  $rootpassword = hiera('profile::mysqlcluster::root_password')
  $statuspassword = hiera('profile::mysqlcluster::status_password')
  $haproxypassword = hiera('profile::mysqlcluster::haproxy_password')

  mysql_user { "root@${master}":
    ensure  => 'absent',
    require => Class['::galera'],
  }->
  mysql_user { 'root@%':
    ensure        => 'present',
    password_hash => mysql_password($rootpassword)
  }->
  mysql_grant { 'root@%/*.*':
    ensure     => 'present',
    options    => ['GRANT'],
    privileges => ['ALL'],
    table      => '*.*',
    user       => 'root@%',
  }

  mysql_user { 'haproxy_check@%':
    ensure        => 'present',
    password_hash => mysql_password($haproxypassword)
  }->
  mysql_grant { 'haproxy_check@%/mysql.user':
    ensure     => 'present',
    options    => ['GRANT'],
    privileges => ['SELECT'],
    table      => 'mysql.user',
    user       => 'haproxy_check@%',
  }
}
