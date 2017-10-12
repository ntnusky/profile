# Installs and configures a puppetmaster 
class profile::services::puppet::server {
  include ::profile::services::puppet::server::config
  include ::profile::services::puppet::server::hiera
  include ::profile::services::puppet::server::haproxy::backend
  include ::profile::services::puppet::server::install
  include ::profile::services::puppet::server::service
}
