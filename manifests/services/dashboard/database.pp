# Installs the dashboard
class profile::services::dashboard::database {
  require ::profile::services::dashboard::install

  exec { '/opt/machineadmin/manage.py migrate --noinput':
    refreshonly => true,
    require     => [
      Vcsrepo['/opt/machineadmin'],
    ],
    subscribe   => Vcsrepo['/opt/machineadmin'],
  }
}
