# This class configures log-inputs from apache
class profile::services::apache::logging {
  $loggservers = lookup('profile::logstash::servers', {
    'value_type'    => Variant[Boolean, Array[String]],
    'default_value' => false,
  })

  # Only set up remote-logging if there are defined any log-servers in hiera. 
  if $loggservers{
    filebeat::input { 'apache':
      paths    => [
        '/var/log/apache/*.log',
      ],
      doc_type => 'log',
      tags     => [ 'apache' ],
    }
  }
}
