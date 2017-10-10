# Configuring galera and maraidb cluster
class profile::mysql::cluster {
  $servers = hiera('profile::mysql::servers')
  
  $master  = hiera('profile::mysqlcluster::master')
  $rootpassword = hiera('profile::mysqlcluster::root_password')
  $statuspassword = hiera('profile::mysqlcluster::status_password')
  $haproxypassword = hiera('profile::mysqlcluster::haproxy_password')

  $management_if = hiera('profile::interfaces::management')
  $management_ip = hiera("profile::interfaces::${management_if}::address")

  $installsensu = hiera('profile::sensu::install', true)
  if ($installsensu) {
    include ::profile::sensu::plugin::mysql
  }

  apt::source { 'galera_mariadb':
    location   => 'http://lon1.mirrors.digitalocean.com/mariadb/repo/10.0/ubuntu',
    repos      => 'main',
    release    => $::lsbdistcodename,
    key        => '177F4010FE56CA3336300305F1656F24C74CD1D8',
    key_server => 'keyserver.ubuntu.com',
    notify     => Exec['apt_update'],
  }

  class { '::galera' :
    galera_servers      => $servers,
    galera_master       => $master,
    galera_package_name => 'galera-3',
    mysql_package_name  => 'mariadb-galera-server-10.0',
    client_package_name => 'mariadb-client-10.0',
    status_password     => $statuspassword,
    vendor_type         => 'mariadb',
    root_password       => $rootpassword,
    local_ip            => $management_ip,
    configure_firewall  => false,
    configure_repo      => false,
    override_options    => {
      'mysqld' => {
        'port'            => '3306',
        'bind-address'    => $management_ip,
        'max_connections' => '1000',
      }
    },
    require             => Apt::Source['galera_mariadb'],
  }

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
