# This class installs and configures remote-logging for our servers.
class profile::baseconfig::logging {
  $loggservers = lookup('profile::logstash::servers', {
    'value_type'    => Variant[Boolean, Array[String]],
    'default_value' => false,
  })

  # Only set up remote-logging if there are defined any log-servers in hiera. 
  if $loggservers{
    include ::profile::baseconfig::logging::system

    # Install and configure filebeat.
    class { 'filebeat':
      enable_conf_modules => true,
      outputs             => {
        'logstash' => {
          'hosts'       => $loggservers,
          'loadbalance' => true,
        },
      },
    }
  }
}
