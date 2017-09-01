# Configures the apache vhost for the dashboard.
class profile::services::dashboard::apache {
  require ::profile::services::apache

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
