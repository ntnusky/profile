# Installs and configures a puppetmaster that both is a CA and registers with
# the LB. 
class profile::services::puppet::aio {
  # TODO: Remove this purge at a later release
  include ::profile::services::dashboard::clients::purge

  include ::profile::services::puppet::backup::ca
  include ::profile::services::puppet::ca::certclean
  include ::profile::services::puppet::server::config
  include ::profile::services::puppet::server::firewall
  include ::profile::services::puppet::server::hiera
  include ::profile::services::puppet::server::haproxy::backend
  include ::profile::services::puppet::server::install
  include ::profile::services::puppet::server::service

  Class['profile::services::puppet::server::install']
  -> Class['profile::services::puppet::server::config']
}
