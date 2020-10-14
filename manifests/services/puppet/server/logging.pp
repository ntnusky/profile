# This class configures log-inputs from puppet
class profile::services::puppet::server::logging {
  $loggservers = lookup('profile::logstash::servers', {
    'value_type'    => Variant[Boolean, Array[String]],
    'default_value' => false,
  })

  # Only set up remote-logging if there are defined any log-servers in hiera. 
  if $loggservers{
    filebeat::input { 'puppetserver':
      paths     => [
        '/var/log/puppetlabs/puppetserver/puppetserver.log',
        '/var/log/puppetlabs/puppetserver/puppetserver-access.log',
        '/var/log/puppetlabs/puppetserver/puppetserver-status.log',
      ],
      doc_type  => 'log',
      multiline => {
        'pattern' => '\\$',
        'negate'  => 'false',
        'match'   => 'before',
      },
      tags      => [ 'puppet-server' ],
    }
  }
}
