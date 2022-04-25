# Configures filebeat to use a certain module
define profile::utilities::logging::module (
  $content = false,
) {
  $loggservers = lookup('profile::logstash::servers', {
    'value_type'    => Variant[Boolean, Array[String]],
    'default_value' => false,
  })

  require ::profile::baseconfig::logging

  # Only set up remote-logging if there are defined any log-servers in hiera.
  if $loggservers {
    if $content {
      $opts = {
        ensure  => 'file',
        content => to_yaml($content),
      }
    } else {
      $opts = {
        ensure  => 'link',
        target  => "/etc/filebeat/modules.d/${name}.yml.disabled",
      }
    }
    file { "/etc/filebeat/modules.d/${name}.yml":
      notify  => Service['filebeat'],
      require => Anchor['filebeat::install::end'],
      *       => $opts,
    }
  }
}
