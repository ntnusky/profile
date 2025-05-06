# Adds an entry to the haproxy tools configfile.
define profile::services::haproxy::tools::collect (
){
  include ::profile::services::haproxy::tools

  $collectall = lookup('profile::haproxy::collect::all', {
    'default_value' => true,
    'value_type'    => Boolean,
  })

  if($collectall) {
    Concat::Fragment <<| tag == "haproxy-${name}" |>>
  } else {
    $region_fallback = lookup('profile::region', {
      'default_value' => undef,
      'value_type'    => Optional[String],
    })
    $region = lookup('profile::haproxy::region', {
      'default_value' => $region_fallback,
      'value_type'    => String,
    })
    Concat::Fragment <<| tag == "haproxy-${name}" and
      tag == "region-${region}" |>>
  }
}
