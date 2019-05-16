# Configures the apache vhost for the dashboard.
class profile::services::dashboard::apache {
  $configfile = lookup('profile::dashboard::configfile', {
    'value_type'    => Stdlib::Absolutepath,
    'default_value' => '/etc/shiftleader/settings.ini',
  })
  $dashboardname = lookup('profile::dashboard::name', Stdlib::Fqdn)
  $dashboardv4name = lookup('profile::dashboard::name::v4only', {
    'value_type'    => Variant[Stdlib::Fqdn, Boolean],
    'default_value' => false,
  })
  $management_if = lookup('profile::interfaces::management', String)
  $mip = $facts['networking']['interfaces'][$management_if]['ip']
  $management_ipv4 = lookup("profile::baseconfig::network::interfaces.${management_if}.ipv4.address", {
    'value_type'    => Stdlib::IP::Address::V4,
    'default_value' => $mip,
  })
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
