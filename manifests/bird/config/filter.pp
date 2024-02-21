# Creates a filter in some bird-config 
define profile::bird::config::filter (
  String  $configfile,
  Array   $prefixes,
  Integer $med = 100,
) {
  concat::fragment { "Bird Filter ${name}":
    target  => $configfile,
    content => epp('profile/bird/filter.epp', {
      'name'     => $name,
      'prefixes' => $prefixes,
      'med'      => $med,
    }),
    order   => '10'
  }
}
