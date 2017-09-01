# Configures the dashboard.
class profile::services::dashboard::config::ldap {
  $configfile = hiera('profile::dashboard::configfile',
      '/etc/machineadmin/settings.ini')
  $ldap_url = hiera('profile::dashboard::ldap::url')
  $ldap_search = hiera('profile::dashboard::ldap::search_base')
  $ldap_domain = hiera('profile::dashboard::ldap::domain')

  ini_setting { 'Machineadmin LDAP Url':
    ensure  => present,
    path    => $configfile,
    section => 'LDAP',
    setting => 'url',
    value   => $ldap_url,
    require => [
              File['/etc/machineadmin'],
            ],
  }

  ini_setting { 'Machineadmin LDAP Search base':
    ensure  => present,
    path    => $configfile,
    section => 'LDAP',
    setting => 'search-base',
    value   => $ldap_search,
    require => [
              File['/etc/machineadmin'],
            ],
  }

  ini_setting { 'Machineadmin LDAP Domain':
    ensure  => present,
    path    => $configfile,
    section => 'LDAP',
    setting => 'domain',
    value   => $ldap_domain,
    require => [
              File['/etc/machineadmin'],
            ],
  }
}
