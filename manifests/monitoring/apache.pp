class profile::monitoring::apache {
  class { '::apache':
    mpm_module => 'prefork',
  }
  include ::apache::mod::rewrite
  include ::apache::mod::prefork
  include ::apache::mod::php
}
