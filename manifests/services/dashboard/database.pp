# Installs the dashboard
class profile::services::dashboard::database {
  require ::profile::services::dashboard::install

  exec { '/opt/shiftleader/manage.py migrate --noinput':
    refreshonly => true,
    require     => [
      Vcsrepo['/opt/shiftleader'],
    ],
    subscribe   => Vcsrepo['/opt/shiftleader'],
  }
}
