# This class configures log-inputs from puppet
class profile::services::puppet::db::logging {
  profile::utilities::logging::file { 'puppetdb':
    paths     => [
      '/var/log/puppetlabs/puppetdb/puppetdb.log',
      '/var/log/puppetlabs/puppetdb/puppetdb-access.log',
      '/var/log/puppetlabs/puppetdb/puppetdb-status.log',
    ],
    multiline => {
      'pattern' => '\\$',
      'negate'  => 'false',
      'match'   => 'before',
    },
    tags      => [ 'puppet-db' ],
  }
}
