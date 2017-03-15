# Install and configure standalone redis-server for sensu
class profile::services::redis {
  class { '::redis':
    config_owner => 'redis',
    config_group => 'redis',
    manage_repo  => true,
  }
}
