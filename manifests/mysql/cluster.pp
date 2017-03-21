# Configuring galera and maraidb cluster
class profile::mysql::cluster {
  # Keepalived settings
  $vrrp_password = hiera('profile::keepalived::vrrp_password')
  $vrid = hiera('profile::mysql::vrrp::id')
  $vrpri = hiera('profile::mysql::vrrp::priority')
  
  $mysql_ip = hiera('profile::mysql::ip')
  $servers = hiera('controller::management::addresses')
  $master  = hiera('profile::mysqlcluster::master')
  $rootpassword = hiera('profile::mysqlcluster::root_password')
  $statuspassword = hiera('profile::mysqlcluster::status_password')

  $management_if = hiera('profile::interfaces::management')
  $management_ip = getvar("::ipaddress_${management_if}")

  require profile::services::keepalived
  include ::profile::sensu::plugin::mysql

  apt::source { 'galera_mariadb':
    location   => 'http://mirror.aarnet.edu.au/pub/MariaDB/repo/10.0/ubuntu',
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
        'bind-address'    => $mysql_ip,
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
  }->
  mysql_grant { 'haproxy_check@%/mysql.user':
    ensure     => 'present',
    options    => ['GRANT'],
    privileges => ['SELECT'],
    table      => 'mysql.user',
    user       => 'haproxy_check@%',
  }
  
  keepalived::vrrp::script { 'check_mysql':
    script => '/usr/bin/killall -0 mysqld',
  }
  
  # Define the virtual addresses
  keepalived::vrrp::instance { 'management-database':
    interface         => $management_if,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${mysql_ip}/32",
    ],
    track_script      => 'check_mysql',
  }
}
