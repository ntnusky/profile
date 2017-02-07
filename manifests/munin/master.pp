# This class installs a munin master, and configures an apache virtual host for
# it.
class profile::munin::master {
  require profile::services::apache

  $munin_url = hiera('profile::munin::url')

  class{ '::munin::master':
    extra_config => [
      'cgiurl_graph /munin-cgi/munin-cgi-graph',
    ],
  }

  munin::plugin { 'munin_stats':
    ensure  => link,
  }

  apache::vhost { "${munin_url} http":
    servername    => $munin_url,
    serveraliases => [$munin_url],
    port          => '80',
    docroot       => '/var/cache/munin/www',
    docroot_owner => 'www-data',
    docroot_group => 'www-data',
    directories   => [
      { path            => '/munin-cgi',
        provider        => 'location',
        require         => 'all granted',
      },
      { path            => '/munin-cgi/munin-cgi-html',
        provider        => 'location',
        require         => 'all granted',
        custom_fragment => '
      <IfModule mod_fcgid.c>
        SetHandler fcgid-script
      </IfModule>
      <IfModule !mod_fcgid.c>
        SetHandler cgi-script
      </IfModule>',
      },
      { path            => '/munin-cgi/munin-cgi-graph',
        provider        => 'location',
        require         => 'all granted',
        custom_fragment => '
      <IfModule mod_fcgid.c>
        SetHandler fcgid-script
      </IfModule>
      <IfModule !mod_fcgid.c>
        SetHandler cgi-script
      </IfModule>',
      },
      { path    => '/var/cache/munin/www',
        require => 'all granted',
        options => ['None'],
      },
      { path    => '/var/cache/munin/www/static',
        require => 'all granted',
        options => ['None'],
      },
    ],
    aliases       => [
      { alias       => '/munin-cgi/static',
        path        => '/var/cache/munin/www/static',
      },
      { scriptalias => '/munin-cgi/munin-cgi-html',
        path        => '/usr/lib/munin/cgi/munin-cgi-html',
      },
      { scriptalias => '/munin-cgi/munin-cgi-graph',
        path        => '/usr/lib/munin/cgi/munin-cgi-graph',
      },
      { scriptalias => '/munin-cgi',
        path        => '/usr/lib/munin/cgi/munin-cgi-html',
      },
    ],
    rewrites       => [
      { rewrite_rule => [
          '^/favicon.ico /var/cache/munin/www/static/favicon.ico [L]',
        ],
      },
      { rewrite_rule => [
          '^/static/(.*) /var/cache/munin/www/static/$1          [L]',
        ],
      },
      { rewrite_rule => [
          '^/munin-cgi/munin-cgi-graph/(.*) /$1',
        ],
      },
      { rewrite_cond => [
          '%{REQUEST_URI}                 !^/static',
        ],
        rewrite_rule => [
          '^/(.*.png)$  /munin-cgi/munin-cgi-graph/$1 [L,PT]',
        ],
      },
      { rewrite_cond => [
          '%{REQUEST_URI}                 !^/static',
        ],
        rewrite_rule => [
          '^/(.*.html)$  /munin-cgi/munin-cgi-html/$1 [L,PT]',
        ],
      },
    ],
  }
}
