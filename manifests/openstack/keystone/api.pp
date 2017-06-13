# Installs and configures the keystone identity API.
class profile::openstack::keystone::api {
  $region = hiera('profile::region')
  $admin_ip = hiera('profile::api::keystone::admin::ip')
  $public_ip = hiera('profile::api::keystone::public::ip')

  $admin_token = hiera('profile::keystone::admin_token')
  $admin_email = hiera('profile::keystone::admin_email')
  $admin_pass = hiera('profile::keystone::admin_password')

  $password = hiera('profile::mysql::keystonepass')
  $mysql_ip = hiera('profile::mysql::ip')
  $database_connection = "mysql://keystone:${password}@${mysql_ip}/keystone"

  require ::profile::openstack::repo

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

  class { '::keystone::roles::admin':
    email        => $admin_email,
    password     => $admin_pass,
    admin_tenant => 'admin',
    require      => Class['::keystone'],
  }

  class { '::keystone::endpoint':
    public_url   => "http://${public_ip}:5000",
    admin_url    => "http://${admin_ip}:35357",
    internal_url => "http://${admin_ip}:5000",
    region       => $region,
    require      => Class['::keystone'],
  }

  class { '::keystone::wsgi::apache':
    servername       => $public_ip,
    servername_admin => $admin_ip,
    ssl              => false,
  }
}
