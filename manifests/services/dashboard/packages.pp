# Installs various packages needed by the dashboard.
class profile::services::dashboard::packages {
  package { [
      'python3-django',
      'python3-django-python3-ldap',
      'python3-mysqldb',
      'python3-passlib',
      'python3-pypureomapi',
    ] :
    ensure => present,
  }
}
