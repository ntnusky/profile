# Installs and configures a puppetmaster 
class profile::services::puppet::server {
  include ::profile::services::dashboard::clients::puppet
  include ::profile::services::puppet::backup::server
  include ::profile::services::puppet::server::config
  include ::profile::services::puppet::server::firewall
  include ::profile::services::puppet::server::hiera
  include ::profile::services::puppet::server::haproxy::backend
  include ::profile::services::puppet::server::install
  include ::profile::services::puppet::server::logging
  include ::profile::services::puppet::server::service

  Class['profile::services::puppet::server::install'] ->
  Class['profile::services::puppet::server::config']
}
