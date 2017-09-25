# This class installs and configures the postgresql server 
class profile::services::postgresql::server {
  $management_if = hiera('profile::interfaces::management')
  $management_ip = hiera("profile::interfaces::${management_if}::address")
  $database_port = hiera('profile::postgres::backend::port', 5433) 
  $password = hiera('profile::postgres::password')

  class { '::postgresql::globals':
    manage_package_repo => true, 
    version             => '9.5',
  }

  class { '::postgresql::server':
    ip_mask_allow_all_users => '0.0.0.0/0',
    listen_addresses        => $management_ip,
    port                    => $databse_port,
    postgres_password       => $password,
  }

  class { '::postgresql::server::contrib': }
}
