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

  include ::profile::services::mysql::backup
  include ::profile::services::mysql::firewall::mysql
  include ::profile::services::mysql::users
  include ::profile::services::mysql::sudo

  class { '::mysql::server':
    root_password           => $rootpassword,
    remove_default_accounts => true,
    override_options        => {
      'mysqld'              => {
        'port'              => '3306',
        'bind-address'      => $::sl2['server']['primary_interface']['ipv4'], 
        'max_connections'   => '1000',
        'net_read_timeout'  => $net_read_timeout,
        'net_write_timeout' => $net_write_timeout,
      }
    },
  }
}
