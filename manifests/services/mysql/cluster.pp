# Installing galera and mariadb cluster
class profile::services::mysql::cluster {
  $servers = hiera('profile::mysqlcluster::servers')
  $master  = hiera('profile::mysqlcluster::master')
  $rootpassword = hiera('profile::mysqlcluster::root_password')
  $statuspassword = hiera('profile::mysqlcluster::status_password')

  $net_read_timeout = hiera('profile::mysqlcluster::timeout::net::read', 30)
  $net_write_timeout = hiera('profile::mysqlcluster::timeout::net::write', 60)

  $management_if = hiera('profile::interfaces::management')
  $mip = $facts['networking']['interfaces'][$management_if]['ip']
  $management_ip = hiera("profile::interfaces::${management_if}::address", $mip)

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
        'port'              => '3306',
        'bind-address'      => $management_ip,
        'max_connections'   => '1000',
        'net_read_timeout'  => $net_read_timeout,
        'net_write_timeout' => $net_write_timeout,
      }
    },
    require             => Apt::Source['galera_mariadb'],
  }
}
