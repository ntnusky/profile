# Installs the dashboard
class profile::services::dashboard::install::staticfiles {
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
    subscribe   => Vcsrepo['/opt/machineadmin'],
  }
}
