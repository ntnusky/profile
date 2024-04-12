# Configure the haproxy frontend for shiftleader.
class profile::services::shiftleader::haproxy::frontend {
  include ::profile::services::haproxy::web

  profile::services::haproxy::tools::collect { 'bk_shiftleader2': }

  haproxy::backend { 'bk_shiftleader2':
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
