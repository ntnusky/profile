# Installs and configures the keystone service on an openstack controller node
# in the SkyHiGh architecture
class profile::openstack::keystone {
  $password = hiera('profile::mysql::keystonepass')
  $allowed_hosts = hiera('profile::mysql::allowed_hosts')
  $mysql_ip = hiera('profile::mysql::ip')
  $vrrp_password = hiera('profile::keepalived::vrrp_password')
  $token_flush_host = hiera('profile::keystone::tokenflush::host')

  $region = hiera('profile::region')
  $admin_ip = hiera('profile::api::keystone::admin::ip')
  $public_ip = hiera('profile::api::keystone::public::ip')
  $vrid = hiera('profile::api::keystone::vrrp::id')
  $vrpri = hiera('profile::api::keystone::vrrp::priority')

  $admin_token = hiera('profile::keystone::admin_token')
  $admin_email = hiera('profile::keystone::admin_email')
  $admin_pass = hiera('profile::keystone::admin_password')

  $public_if = hiera('profile::interfaces::public')
  $management_if = hiera('profile::interfaces::management')

  $database_connection = "mysql://keystone:${password}@${mysql_ip}/keystone"

  $ldap_name = hiera('profile::keystone::ldap_backend::name')
  $ldap_url = hiera('profile::keystone::ldap_backend::url')
  $ldap_user = hiera('profile::keystone::ldap_backend::user')
  $ldap_password = hiera('profile::keystone::ldap_backend::password')
  $ldap_suffix = hiera('profile::keystone::ldap_backend::suffix')
  $ldap_user_tree_dn = hiera('profile::keystone::ldap_backend::user_tree_dn')
  $ldap_user_filter = hiera('profile::keystone::ldap_backend::user_filter')

  #$credential_keys = hiera('profile::keystone::credential_keys')
  #$fernet_keys = hiera('profile::keystone::fernet_keys')
  #  $fernet_setup = hiera('profile::keystone::enable_fernet_setup')

  require ::profile::mysql::cluster
  require ::profile::services::keepalived
  require ::profile::openstack::repo

  if($::hostname == $token_flush_host) {
    file { '/usr/local/bin/keystone-token-flush.sh':
      ensure => file,
      source => 'puppet:///modules/profile/openstack/keystone-token-flush.sh',
      mode   => '0555',
    }
    cron { 'token-flush':
      command => '/usr/local/bin/keystone-token-flush.sh',
      user    => root,
      minute  => [10,40],
    }
  }

  anchor { 'profile::openstack::keystone::begin' :
    require => [
    ],
  }

  class { '::keystone::db::mysql':
    user          => 'keystone',
    password      => $password,
    allowed_hosts => $allowed_hosts,
    dbname        => 'keystone',
    require       => Anchor['profile::openstack::keystone::begin'],
    before        => Anchor['profile::openstack::keystone::end'],
  }

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
    #credential_keys         => $credential_keys,
    #fernet_keys             => $fernet_keys,
    using_domain_config     => true,
    require                 => Anchor['profile::openstack::keystone::begin'],
    before                  => Anchor['profile::openstack::keystone::end'],
  }

  class { '::keystone::roles::admin':
    email        => $admin_email,
    password     => $admin_pass,
    admin_tenant => 'admin',
    require      => Class['::keystone'],
    before       => Anchor['profile::openstack::keystone::end'],
  }

  class { '::keystone::endpoint':
    public_url   => "http://${public_ip}:5000",
    admin_url    => "http://${admin_ip}:35357",
    internal_url => "http://${admin_ip}:5000",
    region       => $region,
    require      => Class['::keystone'],
    before       => Anchor['profile::openstack::keystone::end'],
  }

  class { '::keystone::wsgi::apache':
    servername       => $public_ip,
    servername_admin => $admin_ip,
    ssl              => false,
  }

  keystone::ldap_backend { $ldap_name:
    url                    => $ldap_url,
    user                   => $ldap_user,
    password               => $ldap_password,
    suffix                 => $ldap_suffix,
    query_scope            => sub,
    page_size              => 1000,
    user_tree_dn           => $ldap_user_tree_dn,
    user_filter            => $ldap_user_filter,
    user_objectclass       => person,
    user_id_attribute      => sAMAccountName,
    user_name_attribute    => sAMAccountName,
    user_mail_attribute    => mail,
    user_enabled_attribute => userAccountControl,
    user_enabled_mask      => 2,
    user_enabled_default   => 512,
    #user_attribute_ignore  => ['password', 'tenant_id', 'tenants'],
    #user_allow_create      => False,
    #user_allow_update      => False,
    #user_allow_delete      => False,
    use_tls                => False,
    before                 => Anchor['profile::openstack::keystone::end'],
    require                => Anchor['profile::openstack::keystone::begin'],
  }

  keystone_domain_config {
    "${ldap_name}::identity/list_limit": value => '100';
  }

  keystone_domain { $ldap_name:
    ensure  => present,
    enabled => true,
  }

  keepalived::vrrp::script { 'check_keystone':
    script  => '/usr/bin/killall -0 keystone-all',
    before  => Anchor['profile::openstack::keystone::end'],
    require => Anchor['profile::openstack::keystone::begin'],
  }

  keepalived::vrrp::instance { 'admin-keystone':
    interface         => $management_if,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${admin_ip}/32",
    ],
    track_script      => 'check_keystone',
    before            => Anchor['profile::openstack::keystone::end'],
    require           => Anchor['profile::openstack::keystone::begin'],
  }

  keepalived::vrrp::instance { 'public-keystone':
    interface         => $public_if,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${public_ip}/32",
    ],
    track_script      => 'check_keystone',
    before            => Anchor['profile::openstack::keystone::end'],
    require           => Anchor['profile::openstack::keystone::begin'],
  }

  anchor { 'profile::openstack::keystone::end' : }
}
