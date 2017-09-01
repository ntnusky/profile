# Configures the apache vhost for the dashboard.
class profile::services::dashboard::apache {
  require ::profile::services::apache

  class { 'apache::mod::wsgi':
    wsgi_python_path => '/opt/machineadmin/',
    package_name     => 'libapache2-mod-wsgi-py3',
    mod_path         => '/usr/lib/apache2/modules/mod_wsgi.so',
  }

  $dashboardname = hiera('profile::dashboard::name')

  apache::vhost { "${dashboardname} http":
    servername          => $dashboardname,
    port                => '80',
    docroot             => "/var/www/${dashboardname}",
    directories         => [
      { path    => '/opt/machineadmin/',
        require => 'all granted',
      },
    ],
    custom_fragment     => '
  <Directory /opt/machineadmin/machineadmin>
    <Files wsgi.py>
      Require all granted
    </Files>
  </Directory>',
    wsgi_script_aliases => { '/' => '/opt/machineadmin/machineadmin/wsgi.py' },
    aliases             => [
      { alias => '/static/',
        path  => '/opt/machineadminstatic/',
      },
    ],
  }
}
