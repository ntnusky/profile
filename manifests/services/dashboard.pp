# Installs and configures the management dashboard.
class profile::services::dashboard {
  package { [
      'python3-django',
      'python3-mysqldb',
      'python3-passlib',
      'python3-pypureomapi',
    ] :
    ensure => present,
  }
}
