class profile::mysqlcluster {
  $servers = hiera("controlleraddresses")
  $master  = hiera("profile::mysqlcluster::master")
  $rootpassword = hiera("profile::mysqlcluster::root_password")

  include ::haproxy

  class { '::galera' : 
    galera_servers      => $servers,
    galera_master       => $master,
    galera_package_name => "galera-3",
    vendor_type         => "mariadb",
    root_password       => $rootpassword,
    local_ip            => $::ipaddress_eth0,
    before		=> Service["haproxy"],
    override_options    = {
      'mysqld' => {
        'port' => '3307',
      }
    },
  }
  
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
  }

  ::Haproxy::Balancermember <<| listening_service == 'mysql-cluster' |>>

  @@::haproxy::balancermember { $::fqdn:
    listening_service => 'mysql-cluster',
    server_names      => $::hostname,
    ipaddresses       => $::ipaddress_eth1,
    ports             => '3307',
    options           => 'check',
  }
}
