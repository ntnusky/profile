# Haproxy backend for shiftleader
class profile::services::dashboard::haproxy::backend {
  haproxy::backend { 'bk_shiftleader':
    mode    => 'http',
    options => {
      'balance' => 'source',
      'cookie'  => 'SERVERID insert indirect nocache',
      'option'  => [
        'httplog',
        'log-health-checks',
      ],
    },
  }
}
