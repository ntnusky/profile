# Configures keystone to use an LDAP backend for authentication
class profile::openstack::keystone::ldap {
  $ldap_name = hiera('profile::keystone::ldap_backend::name')
  $ldap_url = hiera('profile::keystone::ldap_backend::url')
  $ldap_user = hiera('profile::keystone::ldap_backend::user')
  $ldap_password = hiera('profile::keystone::ldap_backend::password')
  $ldap_suffix = hiera('profile::keystone::ldap_backend::suffix')
  $ldap_user_tree_dn = hiera('profile::keystone::ldap_backend::user_tree_dn')
  $ldap_user_filter = hiera('profile::keystone::ldap_backend::user_filter')

  require ::profile::openstack::repo

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
    use_tls                => false,
  }

  keystone_domain_config {
    "${ldap_name}::identity/list_limit": value => '100';
  }

  keystone_domain { $ldap_name:
    ensure  => present,
    enabled => true,
  }
}
