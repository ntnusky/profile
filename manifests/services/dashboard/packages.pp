# Installs various packages needed by the dashboard.
class profile::services::dashboard::packages {
  require ::profile::baseconfig::packages

  package { [
      'python3-django',
      'python3-django-python3-ldap',
      'python3-dnspython',
      'python3-mysqldb',
      'python3-passlib',
      'python3-pymysql',
    ] :
    ensure => present,
  }

  package { 'pypureomapi':
    ensure   => present,
    provider => 'pip3',
  }
}
