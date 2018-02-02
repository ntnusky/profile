# Configure haproxy backend for munin
class profile::monitoring::munin::haproxy::backend {
  include ::profile::services::haproxy::web

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
