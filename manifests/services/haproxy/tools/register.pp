# Adds an entry to the haproxy tools configfile.
define profile::services::haproxy::tools::register (
  String[1] $servername,
  String[1] $backendname,
){
  $configfile = lookup({
    'name'          => 'profile::haproxy::tools::configfile',
    'default_value' => '/etc/haproxy/toolconfig.txt',
  })

  @@concat::fragment{ 'haproxytools config header':
    target  => $configfile,
    content => "${servername};${backendname}",
    order   => '10',
    tag     => "haproxy-${backendname}",
  }
}
