# Configure the haproxy frontend for shiftleader.
class profile::services::dashboard::haproxy::frontend {
  require ::profile::services::haproxy::tools
  include ::profile::services::haproxy::web

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
