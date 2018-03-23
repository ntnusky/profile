# Configures the haproxy frontend for horizon
class profile::openstack::horizon::haproxy::frontend {
  include ::profile::services::haproxy::web

  haproxy::backend { 'bk_horizon':
    mode    => 'http',
    options => {
      'balance' => 'source',
      'option'  => [
        'httplog',
        'httpchk',
        'tcpka',
        'tcplog',
      ],
    },
  }
}
