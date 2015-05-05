class profile::mysqlcluster {
  $servers = hiera("controlleraddresses")
  $master  = hiera("profile::mysqlcluster::master")
  $rootpassword = hiera("profile::mysqlcluster::root_password")

  include ::haproxy

  anchor { "profile::mysqlcluster::start" : } ->
  class { '::galera' : 
    galera_servers      => $servers,
    galera_master       => $master,
    galera_package_name => "galera-3",
    vendor_type         => "mariadb",
    root_password       => $rootpassword,
    local_ip            => $::ipaddress_eth1,
    before		=> Service["haproxy"],
    override_options    => {
      'mysqld' => {
        'port' => '3307',
      }
    },
  }->
  mysql_user { "root@${master}":
    ensure     => 'absent',
  }->
  mysql_user { 'root@%':
    ensure     => 'present',
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
  }->
  
  ::haproxy::listen { 'mysql-cluster':
    collect_exported => false,
    mode      => 'tcp',
    ipaddress    => '*',
    ports      => '3306',
    options       => {
      'option'  => [ 'tcplog',
                   'mysql-check user haproxy_check'],
      'balance' => 'roundrobin',
    }
  }->
  anchor { "profile::mysqlcluster::end" : }

  ::Haproxy::Balancermember <<| listening_service == 'mysql-cluster' |>>

  @@::haproxy::balancermember { $::fqdn:
    listening_service => 'mysql-cluster',
    server_names      => $::hostname,
    ipaddresses       => $::ipaddress_eth1,
    ports             => '3307',
    options           => 'check',
  }
}
