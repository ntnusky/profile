# Configure the haproxy frontend for shiftleader.
class profile::services::dashboard::haproxy::frontend {
  include ::profile::services::haproxy::web

  profile::services::haproxy::tools::collect { 'bk_shiftleader': }

  haproxy::backend { 'bk_shiftleader':
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
