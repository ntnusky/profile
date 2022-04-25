# Configures filebeat to use a certain module
define profile::utilities::logging::module (
  $content,
) {
  $loggservers = lookup('profile::logstash::servers', {
    'value_type'    => Variant[Boolean, Array[String]],
    'default_value' => false,
  })

  require ::profile::baseconfig::logging

  # Only set up remote-logging if there are defined any log-servers in hiera.
  if $loggservers {
    file { "/etc/filebeat/modules.d/${name}.yml":
      ensure  => 'file',
      content => to_yaml($content),
      notify  => Service['filebeat'],
      require => Anchor['filebeat::install::end'],
    }
  }
}
