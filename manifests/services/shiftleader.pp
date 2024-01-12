# This class installs and configures both the shiftleader API and frontend.
class profile::services::shiftleader {
  include ::profile::services::apache
  include ::profile::services::shiftleader::haproxy::backend
  include ::shiftleader::web

  $server = lookup('profile::ldap::server', {
    'value_type' => String,
  })
  $username = lookup('profile::ldap::bind::user', {
    'value_type' => String,
  })
  $password = lookup('profile::ldap::bind::password', {
    'value_type' => String,
  })
  $group_member = lookup('profile::ldap::group::attribute::member', {
    'default_value' => 'memberOf',
    'value_type'    => String,
  })
  $group_base = lookup('profile::ldap::group::base', {
    'value_type' => String,
  })
  $user_id = lookup('profile::ldap::user::attribute::id', {
    'default_value' => 'sAMAccountName',
    'value_type'    => String,
  })
  $user_base = lookup('profile::ldap::user::base', {
    'value_type' => String,
  })

  class { '::shiftleader::api':
    puppetapi_cert => false,
    puppetapi_key  => false,
  }

  shiftleader::api::domain { 'NTNU':
    server                 => $server,
    bind_user              => $username,
    bind_pass              => $password,
    group_base             => $group_base,
    group_member_attribute => $group_member,
    user_base              => $user_base,
    user_id_attribute      => $user_id,
  }
}
