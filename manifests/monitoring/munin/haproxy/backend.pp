# Configure haproxy backend for munin
class profile::monitoring::munin::haproxy::backend {
  $installmunin = lookup('profile::munin::install', {
    'default_value' => true,
    'value_type'    => Boolean,
  })

  if($installmunin) {
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
}
