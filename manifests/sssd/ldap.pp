# Defines LDAP authentication via AD with sssd

class profile::sssd::ldap (
  $shell = '/bin/bash'
) {

  $ldapdomain = hiera('profile::sssd::domain')
  $ldapdomaindn = hiera('profile::keystone::ldap_backend::suffix')
  $dc = hiera('profile::sssd::domaincontroller')
  $binduser = hiera('profile::sssd::binduser')
  $pwhash = hiera('profile::sssd::passwordhash')
  $userfilter = hiera('profile::keystone::ldap_backend::user_filter')
  $userbase = hiera('profile::keystone::ldap_backend::user_tree_dn')
  $groupbase = hiera('profile::sssd::group_base')

  class {'::sssd':
    config => {
      'sssd' => {
        'config_file_version' => 2,
        'services'            => ['nss', 'pam'],
        'domains'             => $ldapdomain,
      },
      'nss'  => {
        'filter_groups'        => 'root',
        'filter_user'          => 'root',
        'reconnection_retires' => 3,
      },
      'pam'  => {
      },
      "domain/${ldapdomain}"        => {
        'debug_level'               => '0x400',
        'enumerate'                 => false,
        'case_sensitive'            => false,
        'cache_credentials'         => true,
        'min_id'                    => 100,
        'ignore_group_members'      => true,
        'id_provider'               => 'ldap',
        'auth_provider'             => 'ldap',
        'access_provider'           => 'ldap',
        'chpass_provider'           => 'ldap',
        'ldap_id_use_start_tls'     => true,
        'ldap_schema'               => 'ad',
        'ldap_id_mapping'           => true,
        'ldap_access_filter'        => $userfilter,
        'ldap_page_size'            => 1000,
        'ldap_referrals'            => false,
        'ldap_user_search_base'     => $userbase,
        'ldap_user_objectsid'       => 'objectSid',
        'ldap_group_search_base'    => $groupbase,
        'ldap_user_object_class'    => 'user',
        'ldap_user_name'            => 'sAMAccountName',
        'ldap_user_gecos'           => 'displayName',
        'ldap_group_object_class'   => 'group',
        'ldap_group_name'           => 'sAMAccountName',
        'override_homedir'          => '/home/%u',
        'override_shell'            => $shell,
        'override_gid'              => 100,
        'ldap_uri'                  => "ldaps://${dc}",
        'ldap_default_bind_dn'      => $binduser,
        'ldap_default_authtok_type' => 'obfuscated_password',
        'ldap_default_authtok'      => $pwhash,
      }
    }
  }
}
