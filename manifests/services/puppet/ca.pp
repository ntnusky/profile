# Installs and configures a puppetmaster 
class profile::services::puppet::ca {
  # TODO: Remove this purge at a later release
  include ::profile::services::dashboard::clients::purge

  include ::profile::services::puppet::backup::ca
  include ::profile::services::puppet::server::config
  include ::profile::services::puppet::server::firewall
  include ::profile::services::puppet::server::hiera
  include ::profile::services::puppet::server::install
  include ::profile::services::puppet::server::service
  include ::shiftleader::worker::puppet
  include ::shiftleader::worker::puppet::ca
}
