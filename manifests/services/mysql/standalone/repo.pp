# Installs the mysql-repo for mariaBD
class profile::services::mysql::standalone::repo {
  $mariadb_version = lookup('profile::mariadb::version', {
    'default_value' => '10.6',
    'value_type'    => String,
  })

  apt::source { 'mariadb':
    location => "https://deb.mariadb.org/${mariadb_version}/ubuntu",
    release  => $::facts['os']['codename'],
    repos    => 'main',
    key      => {
      id     => '177F4010FE56CA3336300305F1656F24C74CD1D8',
      server => 'hkp://keyserver.ubuntu.com:80',
    },
    include => {
      src   => false,
      deb   => true,
    },
  }
}
