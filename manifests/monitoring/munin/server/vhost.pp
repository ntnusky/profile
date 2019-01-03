# This define configures an apache vhost for a munin dashboard.
define profile::monitoring::munin::server::vhost {
  require profile::services::apache

  $management_netv6 = hiera('profile::networks::management::ipv6::prefix', false)
  $management_if = hiera('profile::interfaces::management')
  $mip = $facts['networking']['interfaces'][$management_if]['ip']
  $management_ipv4 = hiera("profile::interfaces::${management_if}::address", $mip)

  if ( $management_netv6 ) {
    $management_ipv6 = $::facts['networking']['interfaces'][$management_if]['ip6']
    $ip = concat([], $management_ipv4, $management_ipv6)
  } else {
    $ip = [$management_ipv4]
  }

  apache::vhost { "${name} http":
    servername        => $name,
    serveraliases     => [$name],
    port              => '80',
    ip                => $ip,
    docroot           => '/var/cache/munin/www',
    docroot_owner     => 'www-data',
    docroot_group     => 'www-data',
    access_log_format => 'forwarded',
    directories       => [
      { path     => '/munin-cgi',
        provider => 'location',
        require  => 'all granted',
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
      { path    => '/etc/munin/static',
        require => 'all granted',
        options => ['None'],
      },
    ],
    aliases           => [
      { alias => '/munin-cgi/static',
        path  => '/etc/munin/static',
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
    rewrites          => [
      { rewrite_rule => [
          '^/favicon.ico /etc/munin/static/favicon.ico [L]',
        ],
      },
      { rewrite_rule => [
          '^/static/(.*) /etc/munin/static/$1          [L]',
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
