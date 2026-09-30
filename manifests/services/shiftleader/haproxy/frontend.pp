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
    $overrides = lookup('profile::haproxy::region::override', {
      'default_value' => {},
      'value_type'    => Hash[String, Array[String]],
    })

    # If there is defined an override-list for a certain haproxy-backend, use
    # that list as the list of regions to collect servers from.
    if('bk_shiftleader2' in $overrides) {
      $regions = [] + $overrides['bk_shiftleader2']

    # Otherwise use the haproxy-servers region
    } else {
      $regions = [ $region_fallback ]
    }

    $regions.each | $region | {
      Haproxy::Balancermember <<| listening_service == 'bk_shiftleader2' and
          tag == "region-${region}" |>>
    }
  }
}
