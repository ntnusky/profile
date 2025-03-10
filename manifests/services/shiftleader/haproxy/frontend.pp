# Configure the haproxy frontend for shiftleader.
class profile::services::shiftleader::haproxy::frontend {
  $collectall = lookup('profile::haproxy::collect::all', {
    'default_value' => true,
    'value_type'    => Boolean,
  })

  include ::profile::services::haproxy::web

  profile::services::haproxy::tools::collect { 'bk_shiftleader2': }

  haproxy::backend { 'bk_shiftleader2':
    collect_exported => false,
    mode             => 'http',
    options          => {
      'balance' => 'source',
      'option'  => [
        'httplog',
        'log-health-checks',
      ],
    },
  }

  if($collectall) {
    Haproxy::Balancermember <<| listening_service == 'bk_shiftleader2' |>>
  } else {
    $region_fallback = lookup('profile::region', {
      'default_value' => undef,
      'value_type'    => Optional[String],
    })
    $region = lookup('profile::haproxy::region', {
      'default_value' => $region_fallback,
      'value_type'    => String,
    })

    Haproxy::Balancermember <<| listening_service == 'bk_shiftleader2' and
        tag == "region-${region}" |>>
  }
}
