# This class configures log-inputs from puppet
class profile::services::puppet::server::logging {
  profile::utilities::logging::file { 'puppetserver':
    paths     => [
      '/var/log/puppetlabs/puppetserver/puppetserver.log',
      '/var/log/puppetlabs/puppetserver/puppetserver-status.log',
    ],
    multiline => {
      'pattern' => '\\$',
      'negate'  => 'false',
      'match'   => 'before',
    },
    tags      => [ 'puppet-server' ],
  }

  profile::utilities::logging::module { 'apache' :
    content => [{
      'module' => 'apache',
      'access' => {
        'enabled'   => true,
        'var.paths' => [
          '/var/log/puppetlabs/puppetserver/puppetserver-access.log',
        ]
      }
    }]
  }
}
