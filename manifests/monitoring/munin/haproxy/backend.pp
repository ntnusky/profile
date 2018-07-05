# Configure haproxy backend for munin
class profile::monitoring::munin::haproxy::backend {
  include ::profile::services::haproxy::web

  profile::services::haproxy::tools::collect { 'bk_munin': }

  haproxy::backend { 'bk_munin':
    mode    => 'http',
    options => {
      'balance' => 'source',
      'option'  => [
        'httplog',
        'log-health-checks',
      ],
    },
  }
}
