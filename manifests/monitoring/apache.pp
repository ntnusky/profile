class profile::monitoring::apache {
  class { '::apache':
    mpm_module    => 'prefork',
    purge_configs => false,
  }
  include ::apache::mod::rewrite
  include ::apache::mod::prefork
  include ::apache::mod::php
}
