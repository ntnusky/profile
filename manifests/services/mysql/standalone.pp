# Installs a stand-alone mysql server 
class profile::services::mysql::standalone {
  # Get the MySQL root-password
  $rootpassword = lookup('profile::mysql::root_password', String)

  # Allow setting timeouts in hiera
  $net_read_timeout = lookup('profile::mysql::timeout::net::read', {
    'value_type'    => Integer,
    'default_value' => 30,
  })
  $net_write_timeout = lookup('profile::mysql::timeout::net::write', {
    'value_type'    => Integer,
    'default_value' => 60,
  })
  $innodb_buffer_pool_size = lookup('profile::mysql::innodb_buffer_pool_size', {
    'default_value' => 1073741824, # We default to 1GB. 
    'value_type'    => Integer,
  })

  $zabbix_servers = lookup('profile::zabbix::agent::servers', {
    'default_value' => [],
    'value_type'    => Array[Stdlib::IP::Address::Nosubnet],
  })

  if($zabbix_servers =~ Array[Stdlib::IP::Address::Nosubnet, 1]) {
    include ::profile::services::mysql::users::zabbixagent
  }

  include ::profile::services::mysql::backup
  include ::profile::services::mysql::firewall::mysql
  include ::profile::services::mysql::haproxy::backend
  require ::profile::services::mysql::standalone::repo
  include ::profile::services::mysql::sudo

  class { '::mysql::server':
    package_name            => 'mariadb-server',
    service_name            => 'mariadb',
    root_password           => $rootpassword,
    remove_default_accounts => true,
    override_options        => {
      'mysqld'                    => {
        'port'                    => '3306',
        'bind-address'            =>
          $::sl2['server']['primary_interface']['ipv4'],
        'innodb_buffer_pool_size' => $innodb_buffer_pool_size,
        'max_connections'         => '750',
        'net_read_timeout'        => $net_read_timeout,
        'net_write_timeout'       => $net_write_timeout,
        'ssl_ca'                  => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
        'ssl_cert'                =>
          "/etc/puppetlabs/puppet/ssl/certs/${::fqdn}.pem",
        'ssl_key'                 =>
          "/etc/puppetlabs/puppet/ssl/private_keys/${::fqdn}.pem",
      }
    },
  }

  class { 'mysql::client':
    package_name    => 'mariadb-client',
  }

  Apt::Source['mariadb']
  ~> Class['apt::update']
  -> Class['mysql::server']
}
