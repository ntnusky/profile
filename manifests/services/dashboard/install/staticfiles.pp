# Installs the dashboard
class profile::services::dashboard::install::staticfiles {
  file { '/opt/shiftleaderstatic':
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  exec { '/opt/shiftleader/manage.py collectstatic --noinput':
    refreshonly => true,
    require     => [
      Vcsrepo['/opt/shiftleader'],
      File['/opt/shiftleaderstatic'],
    ],
    subscribe   => Vcsrepo['/opt/shiftleader'],
  }
}
