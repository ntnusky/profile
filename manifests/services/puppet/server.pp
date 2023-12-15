# Installs and configures a puppetmaster 
class profile::services::puppet::server {
  $sl_version = lookup('profile::shiftleader::major::version', {
    'default_value' => 1,
    'value_type'    => Integer,
  })

  if($sl_version == 1) {
    include ::profile::services::dashboard::clients::puppet
  } else {
    include ::shiftleader::worker::puppet
  }

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
