# Installs a stand-alone mysql server 
class profile::services::mysql::standalone {
  # Get the MySQL root-password
  $rootpassword = lookup('profile::mysqlcluster::root_password', String)

  # Determine the management-IP for the server; either through the now obsolete
  # hiera-keys, or through the sl2-data:
  #  TODO: Remove the old-fashioned lookups. 
  $man_if = lookup('profile::interfaces::management', {
    'default_value' => undef,
    'value_type'    => Optional[String],
  })
  if($man_if) {
    $mip = $facts['networking']['interfaces'][$man_if]['ip']
    $management_ip = lookup("profile::baseconfig::network::interfaces.${man_if}.ipv4.address", {
      'value_type'    => Stdlib::IP::Address::V4,
      'default_value' => $mip,
    })
  } else {
    $management_ip = $::sl2['server']['primary_interface']['ipv4']
  }

  # Allow setting timeouts in hiera
  $net_read_timeout = lookup('profile::mysqlcluster::timeout::net::read', {
    'value_type'    => Integer,
    'default_value' => 30,
  })
  $net_write_timeout = lookup('profile::mysqlcluster::timeout::net::write', {
    'value_type'    => Integer,
    'default_value' => 60,
  })

  include ::profile::services::mysql::backup
  include ::profile::services::mysql::databases
  include ::profile::services::mysql::firewall::mysql
  include ::profile::services::mysql::monitoring
  include ::profile::services::mysql::users
  include ::profile::services::mysql::sudo

  class { '::mysql::server':
    root_password           => $rootpassword,
    remove_default_accounts => true,
    override_options        => {
      'mysqld'              => {
        'port'              => '3306',
        'bind-address'      => $management_ip,
        'max_connections'   => '1000',
        'net_read_timeout'  => $net_read_timeout,
        'net_write_timeout' => $net_write_timeout,
      }
    },
  }
}
