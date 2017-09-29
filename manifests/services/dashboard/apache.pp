# Configures the apache vhost for the dashboard.
class profile::services::dashboard::apache {
  $configfile = hiera('profile::dashboard::configfile',
      '/etc/machineadmin/settings.ini')
  $dashboardname = hiera('profile::dashboard::name')

  require ::profile::services::apache
  include ::profile::services::dashboard::install::staticfiles

  # Install and configure apache mod wsgi
  class { 'apache::mod::wsgi':
    wsgi_python_path => '/opt/machineadmin/',
    package_name     => 'libapache2-mod-wsgi-py3',
    mod_path         => '/usr/lib/apache2/modules/mod_wsgi.so',
  }

  $fragment = '<Directory /opt/machineadmin/dashboard>
  <Files wsgi.py>
    Require all granted
  </Files>
</Directory>'

  apache::vhost { "${dashboardname} http":
    servername          => $dashboardname,
    port                => '80',
    docroot             => "/var/www/${dashboardname}",
    directories         => [
      { path    => '/opt/machineadmin/',
        require => 'all granted',
      },
    ],
    custom_fragment     => $fragment,
    wsgi_script_aliases => { '/' => '/opt/machineadmin/dashboard/wsgi.py' },
    aliases             => [{
        alias => '/static/',
        path  => '/opt/machineadminstatic/',
      },
    ],
  }

  Vcsrepo['/opt/machineadmin'] ~> Service['httpd']

  ini_setting { 'Machineadmin staticpath':
    ensure  => present,
    path    => $configfile,
    section => 'general',
    setting => 'staticpath',
    value   => '/opt/machineadminstatic',
    require => [
              File['/etc/machineadmin'],
            ],
    before  => Exec['/opt/machineadmin/manage.py collectstatic --noinput'],
  }
}
