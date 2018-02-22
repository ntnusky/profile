# Performs the base configuration of keystone 
class profile::openstack::keystone::base {
  $region = hiera('profile::region')
  $admin_ip = hiera('profile::api::keystone::admin::ip')
  $public_ip = hiera('profile::api::keystone::public::ip')

  $admin_endpoint = hiera('profile::keystone::endpoint::admin',
      "http://${admin_ip}")
  $public_endpoint = hiera('profile::keystone::endpoint::public',
      "http://${public_ip}")

  $admin_email = hiera('profile::keystone::admin_email')
  $admin_pass = hiera('profile::keystone::admin_password')
  $admin_token = hiera('profile::keystone::admin_token')

  $mysql_password = hiera('profile::mysql::keystonepass')
  $mysql_ip = hiera('profile::mysql::ip')
  $db_con = "mysql://keystone:${mysql_password}@${mysql_ip}/keystone"

  require ::profile::openstack::repo
  require ::profile::openstack::keystone::database
  include ::profile::openstack::keystone::tokenflush

  class { '::keystone':
    admin_token             => $admin_token,
    admin_password          => $admin_pass,
    database_connection     => $db_con,
    debug                   => true,
    enabled                 => false,
    admin_bind_host         => '0.0.0.0',
    admin_endpoint          => "${admin_endpoint}:35357/",
    public_endpoint         => "${public_endpoint}:5000/",
    token_provider          => 'uuid',
    enable_fernet_setup     => true,
    enable_credential_setup => true,
    using_domain_config     => true,
  }

  class { '::keystone::roles::admin':
    email        => $admin_email,
    password     => $admin_pass,
    admin_tenant => 'admin',
    require      => Class['::keystone'],
  }

  class { '::keystone::wsgi::apache':
    servername       => $public_ip,
    servername_admin => $admin_ip,
    ssl              => false,
  }
}
