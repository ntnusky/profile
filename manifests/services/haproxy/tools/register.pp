# Adds an entry to the haproxy tools configfile.
define profile::services::haproxy::tools::register (
  String[1] $servername,
  String[1] $backendname,
  Boolean   $exportresource = true,
){
  $configfile = lookup({
    'name'          => 'profile::haproxy::tools::configfile',
    'default_value' => '/etc/haproxy/toolconfig.csv',
  })

  if($exportresource) {
    $region = lookup('ntnuopenstack::region', String)

    @@concat::fragment{ "haproxy config ${servername};${backendname}":
      target  => $configfile,
      content => "${servername};${backendname}",
      order   => '10',
      tag     => [
        "haproxy-${backendname}",
        "region-${region}",
      ],
    }
  } else {
    concat::fragment{ "haproxy config ${servername};${backendname}":
      target  => $configfile,
      content => "${servername};${backendname}",
      order   => '10',
    }
  }
}
