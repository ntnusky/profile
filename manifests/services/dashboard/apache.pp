# Configures the apache vhost for the dashboard.
class profile::services::dashboard::apache {
  $configfile = hiera('profile::dashboard::configfile',
      '/etc/shiftleader/settings.ini')
  $dashboardname = hiera('profile::dashboard::name')
  $dashboardv4name = hiera('profile::dashboard::name::v4only', false)
  $management_if = hiera('profile::interfaces::management')
  $mip = $facts['networking']['interfaces'][$management_if]['ip']
  $management_ipv4 = hiera("profile::interfaces::${management_if}::address", $mip)
  $management_ipv6 = $::facts['networking']['interfaces'][$management_if]['ip6']

  require ::profile::services::apache
  include ::profile::services::dashboard::haproxy::backend
  include ::profile::services::dashboard::install::staticfiles

  # Install and configure apache mod wsgi
  class { 'apache::mod::wsgi':
    wsgi_python_path => '/opt/shiftleader/',
    package_name     => 'libapache2-mod-wsgi-py3',
    mod_path         => '/usr/lib/apache2/modules/mod_wsgi.so',
  }

  $fragment = '<Directory /opt/shiftleader/dashboard>
  <Files wsgi.py>
    Require all granted
  </Files>
</Directory>'

  apache::vhost { "${dashboardname} http":
    servername          => $dashboardname,
    port                => '80',
    ip                  => concat([], $management_ipv4, $management_ipv6),
    add_listen          => false,
    docroot             => "/var/www/${dashboardname}",
    directories         => [
      { path    => '/opt/shiftleader/',
        require => 'all granted',
      },
    ],
    access_log_format   => 'forwarded',
    custom_fragment     => $fragment,
    wsgi_script_aliases => { '/' => '/opt/shiftleader/dashboard/wsgi.py' },
    aliases             => [{
        alias => '/static/',
        path  => '/opt/shiftleaderstatic/',
      },
    ],
  }

  if($dashboardv4name) {
    apache::vhost { "${dashboardv4name} http":
      servername          => $dashboardv4name,
      port                => '80',
      ip                  => concat([], $management_ipv4, $management_ipv6),
      add_listen          => false,
      docroot             => "/var/www/${dashboardname}",
      directories         => [
        { path    => '/opt/shiftleader/',
          require => 'all granted',
        },
      ],
      access_log_format   => 'forwarded',
      custom_fragment     => $fragment,
      wsgi_script_aliases => { '/' => '/opt/shiftleader/dashboard/wsgi.py' },
      aliases             => [{
          alias => '/static/',
          path  => '/opt/shiftleaderstatic/',
        },
      ],
    }
  }

  Vcsrepo['/opt/shiftleader'] ~> Service['httpd']

  ini_setting { 'Machineadmin staticpath':
    ensure  => present,
    path    => $configfile,
    section => 'general',
    setting => 'staticpath',
    value   => '/opt/shiftleaderstatic',
    require => [
              File['/etc/shiftleader'],
            ],
    before  => Exec['/opt/shiftleader/manage.py collectstatic --noinput'],
  }
}
