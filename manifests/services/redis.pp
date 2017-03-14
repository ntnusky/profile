# Install and configure standalone redis-server for sensu
class profile::services::redis {
  class { '::redis':
  }
}
