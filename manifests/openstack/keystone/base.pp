# Performs the base configuration of keystone 
class profile::openstack::keystone::base {
  $admin_ip = hiera('profile::api::keystone::admin::ip')
  $public_ip = hiera('profile::api::keystone::public::ip')

  $admin_token = hiera('profile::keystone::admin_token')
  $admin_pass = hiera('profile::keystone::admin_password')

  $password = hiera('profile::mysql::keystonepass')
  $mysql_ip = hiera('profile::mysql::ip')
  $database_connection = "mysql://keystone:${password}@${mysql_ip}/keystone"

  require ::profile::openstack::repo
  require ::profile::openstack::keystone::database
  require ::profile::openstack::keystone::tokenflush

  class { '::keystone':
    admin_token             => $admin_token,
    admin_password          => $admin_pass,
    database_connection     => $database_connection,
    debug                   => true,
    enabled                 => false,
    admin_bind_host         => '0.0.0.0',
    admin_endpoint          => "http://${admin_ip}:35357/",
    public_endpoint         => "http://${public_ip}:5000/",
    token_provider          => 'uuid',
    enable_fernet_setup     => true,
    enable_credential_setup => true,
    using_domain_config     => true,
  }
}
