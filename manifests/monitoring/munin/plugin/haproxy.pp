# This class installs the munin plugins which monitors puppet statistics 
class profile::monitoring::munin::plugin::haproxy {
  munin::plugin { "haproxy_bk_puppetserver":
    ensure => link,
    target => 'haproxy_',
    config => ['env.url http://localhost:9000/haproxy-status;csv;norefresh'],
  }
  munin::plugin { "haproxy_ft_puppetserver":
    ensure => link,
    target => 'haproxy_',
    config => ['env.url http://localhost:9000/haproxy-status;csv;norefresh'],
  }
  munin::plugin { "haproxy_ng":
    ensure => link,
    config => ['env.url http://localhost:9000/haproxy-status;csv;norefresh'],
  }
}
