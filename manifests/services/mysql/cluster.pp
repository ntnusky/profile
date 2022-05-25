# Installing galera and mariadb cluster
class profile::services::mysql::cluster {
  $servers = lookup('profile::mysqlcluster::servers', Array[Stdlib::IP::Address::V4])
  $master  = lookup('profile::mysqlcluster::master', Stdlib::Fqdn)
  $rootpassword = lookup('profile::mysqlcluster::root_password', String)
  $statuspassword = lookup('profile::mysqlcluster::status_password', String)

  $net_read_timeout = lookup('profile::mysqlcluster::timeout::net::read', {
    'value_type'    => Integer,
    'default_value' => 30,
  })
  $net_write_timeout = lookup('profile::mysqlcluster::timeout::net::write', {
    'value_type'    => Integer,
    'default_value' => 60,
  })
  $mariadb_version = lookup('profile::mysqlcluster::mariadb::version', String)
  $management_if = lookup('profile::interfaces::management', String)
  $mip = $facts['networking']['interfaces'][$management_if]['ip']
  $management_ip = lookup("profile::baseconfig::network::interfaces.${management_if}.ipv4.address", {
    'value_type'    => Stdlib::IP::Address::V4,
    'default_value' => $mip,
  })

  include ::profile::services::mysql::backup
  include ::profile::services::mysql::databases
  include ::profile::services::mysql::firewall::mysql
  include ::profile::services::mysql::firewall::galera
  include ::profile::services::mysql::haproxy::backend
  include ::profile::services::mysql::logging
  include ::profile::services::mysql::monitoring
  include ::profile::services::mysql::users
  include ::profile::services::mysql::sudo

  class { '::galera' :
    cluster_name        => 'my_wsrep_cluster',
    create_root_my_cnf  => false,
    galera_servers      => $servers,
    galera_master       => $master,
    status_password     => $statuspassword,
    vendor_type         => 'mariadb',
    vendor_version      => $mariadb_version,
    root_password       => $rootpassword,
    local_ip            => $management_ip,
    configure_firewall  => false,
    configure_repo      => true,
    status_check        => false,
    validate_connection => false,
    override_options    => {
      'mysqld'                   => {
        'port'                   => '3306',
        'bind-address'           => $management_ip,
        'max_connections'        => '1000',
        'net_read_timeout'       => $net_read_timeout,
        'net_write_timeout'      => $net_write_timeout,
        'ssl-disable'            => true,
        'wsrep_provider_options' => '"gcache.size=2G"',
      }
    },
    require             => [
      Class['::profile::services::mysql::firewall::mysql'],
      Class['::profile::services::mysql::firewall::galera'],
    ],
  }

  mysql_user { "root@${master}":
    ensure  => 'absent',
    require => Class['::galera'],
  }

  systemd::dropin_file { 'limits.conf':
    unit    => 'mariadb.service',
    source  => 'puppet:///modules/profile/mysql/limits.conf',
    require => Class['::galera'],
    notify  => Service['mysqld'],
  }
}
