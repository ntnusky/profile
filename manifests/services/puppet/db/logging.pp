# This class configures log-inputs from puppet
class profile::services::puppet::db::logging {
  $loggservers = lookup('profile::logstash::servers', {
    'value_type'    => Variant[Boolean, Array[String]],
    'default_value' => false,
  })

  # Only set up remote-logging if there are defined any log-servers in hiera. 
  if $loggservers{
    filebeat::input { 'puppetdb':
      paths     => [
        '/var/log/puppetlabs/puppetdb/puppetdb.log',
        '/var/log/puppetlabs/puppetdb/puppetdb-access.log',
        '/var/log/puppetlabs/puppetdb/puppetdb-status.log',
      ],
      doc_type  => 'log',
      multiline => {
        'pattern' => '\\$',
        'negate'  => 'false',
        'match'   => 'before',
      },
      tags      => [ 'puppet-db' ],
    }
  }
}
