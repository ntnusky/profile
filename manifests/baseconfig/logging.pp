# This class installs and configures logstash
class profile::baseconfig::logging {
  $loggservers = lookup('profile::logstash::servers', {
    'value_type'    => Variant[Boolean, Array[String]],
    'default_value' => false,
  })
# Dersom $loggservers ikke er definert, ikke installer
  if $loggservers{
    class { 'filebeat':
      outputs => {
        'logstash' => {
          'hosts'       => $loggservers,
          'loadbalance' => true,
        },
      },
    }

    filebeat::input { 'syslogs':
      paths    => [
        '/var/log/*log',
        '/var/log/*/*log',
        '/var/log/*/*/*log',
      ],
      doc_type => 'log',
    }
  }
}
