# Haproxy config for uchiwa
class profile::sensu::uchiwa::haproxy {
  include ::profile::services::haproxy::web

  profile::services::haproxy::tools::collect { 'bk_uchiwa': }

  haproxy::backend { 'bk_uchiwa':
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
