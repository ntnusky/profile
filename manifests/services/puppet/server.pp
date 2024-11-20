# Installs and configures a puppetmaster 
class profile::services::puppet::server {
  # TODO: Remove this purge at a later release
  include ::profile::services::dashboard::clients::purge

  include ::profile::services::puppet::backup::server
  include ::profile::services::puppet::server::config
  include ::profile::services::puppet::server::firewall
  include ::profile::services::puppet::server::hiera
  include ::profile::services::puppet::server::haproxy::backend
  include ::profile::services::puppet::server::install
  include ::profile::services::puppet::server::logging
  include ::profile::services::puppet::server::service
  include ::shiftleader::worker::puppet

  Class['profile::services::puppet::server::install'] ->
  Class['profile::services::puppet::server::config']
}
