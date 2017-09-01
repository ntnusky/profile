# Installs the dashboard
class profile::services::dashboard::install {
  vcsrepo { '/opt/machineadmin':
    ensure   => latest,
    provider => git,
    source   => 'git://git.rothaugane.com/machineadmin.git',
    revision => 'master',
    notify   => [
      Exec['/opt/machineadmin/manage.py migrate --noinput'],
      Exec['/opt/machineadmin/manage.py collectstatic --noinput'],
      Service['httpd'],
    ],
    require  => [
      Class['::profile::services::dashboard::config'],
      Class['::profile::services::dashboard::packages'],
    ],
  }

  exec { '/opt/machineadmin/manage.py migrate --noinput':
    refreshonly => true,
    require     => [
      Vcsrepo['/opt/machineadmin'],
    ],
  }

  file { '/opt/machineadminstatic':
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  exec { '/opt/machineadmin/manage.py collectstatic --noinput':
    refreshonly => true,
    require     => [
      Vcsrepo['/opt/machineadmin'],
      File['/opt/machineadminstatic'],
    ],
  }
}
