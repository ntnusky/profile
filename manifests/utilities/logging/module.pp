# Configures filebeat to use a certain module
define profile::utilities::logging::module {
  $loggservers = lookup('profile::logstash::servers', {
    'value_type'    => Variant[Boolean, Array[String]],
    'default_value' => false,
  })

  require ::profile::baseconfig::logging

  # Only set up remote-logging if there are defined any log-servers in hiera.
  if $loggservers {
    file { "/etc/filebeat/modules.d/${name}.yml":
      ensure => 'link',
      target => "/etc/filebeat/modules.d/${name}.yml.disabled",
    }
  }
}
