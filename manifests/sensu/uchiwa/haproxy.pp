# Haproxy config for uchiwa
class profile::sensu::uchiwa::haproxy {
  $installsensu = lookup('profile::sensu::install', {
    'default_value' => true,
    'value_type'    => Boolean,
  })

  if($installsensu) {
    include ::profile::services::haproxy::web

    profile::services::haproxy::tools::collect { 'bk_uchiwa': }

    haproxy::backend { 'bk_uchiwa':
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
