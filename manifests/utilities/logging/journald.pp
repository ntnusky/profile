# Configures filebeat to ingest a certain journald log
define profile::utilities::logging::journald (
  String        $unit = $name,
  Array[String] $tags = [],
){
  $loggservers = lookup('profile::logstash::servers', {
    'value_type'    => Variant[Boolean, Array[String]],
    'default_value' => false,
  })

  require ::profile::baseconfig::logging

  # Only set up remote-logging if there are defined any log-servers in hiera. 
  if $loggservers{
    $content = [{
      'type'            => 'journald',
      'id'              => $unit,
      'include_matches' => [
        "_SYSTEMD_UNIT=${unit}",
      ],
      'tags'            => $tags,
    }]

    file { "/etc/filebeat/conf.d/${name}.yml":
      ensure  => 'file',
      content => to_yaml($content),
      notify  => Service['filebeat'],
      require => Anchor['filebeat::install::end'],
    }
  }
}
