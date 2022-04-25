# Configures filebeat to ingest a certain file
define profile::utilities::logging::file (
  Array[String]        $paths,
  String               $doc_type   = 'log',
  Hash[String, String] $multiline = {},
){
  $loggservers = lookup('profile::logstash::servers', {
    'value_type'    => Variant[Boolean, Array[String]],
    'default_value' => false,
  })
  
  require ::profile::baseconfig::logging

  # Only set up remote-logging if there are defined any log-servers in hiera. 
  if $loggservers{
    filebeat::input { $name:
      paths     => $paths,
      doc_type  => $doc_type,
      multiline => $multiline,
    }
  }
}
