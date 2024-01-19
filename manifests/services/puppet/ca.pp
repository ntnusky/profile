# Installs and configures a puppetmaster 
class profile::services::puppet::ca {
  $sl_version = lookup('profile::shiftleader::major::version', {
    'default_value' => 1,
    'value_type'    => Integer,
  })

  if($sl_version == 1) {
    include ::profile::services::dashboard::clients::puppet
    include ::profile::services::puppet::ca::certclean
  } else {
    include ::shiftleader::worker::puppet
    include ::shiftleader::worker::puppet::ca
  }

  include ::profile::services::puppet::backup::ca
  include ::profile::services::puppet::server::config
  include ::profile::services::puppet::server::firewall
  include ::profile::services::puppet::server::hiera
  include ::profile::services::puppet::server::install
  include ::profile::services::puppet::server::service
}
