# Adds an entry to the haproxy tools configfile.
define profile::services::haproxy::tools::register (
  String[1] $servername,
  String[1] $backendname,
  Boolean   $export       = true,
){
  $configfile = lookup({
    'name'          => 'profile::haproxy::tools::configfile',
    'default_value' => '/etc/haproxy/toolconfig.csv',
  })

  if($export) {
    @@concat::fragment{ "haproxy config ${servername};${backendname}":
      target  => $configfile,
      content => "${servername};${backendname}",
      order   => '10',
      tag     => "haproxy-${backendname}",
    }
  } else {
    concat::fragment{ "haproxy config ${servername};${backendname}":
      target  => $configfile,
      content => "${servername};${backendname}",
      order   => '10',
    }
  }
}
