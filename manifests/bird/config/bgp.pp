# Configures bird to communicate using bgp
define profile::bird::config::bgp (
  String $configfile,
  String $filtername,
  Integer $aslocal,
  Integer $asremote,
  String $neighbourip,
) {
  concat::fragment { "Bird BGP ${name}":
    target  => $configfile,
    content => epp('profile/bird/bgp.epp', {
      'filtername'  => $filtername,
      'aslocal'     => $aslocal,
      'asremote'    => $asremote,
      'neighbourIP' => $neighbourip,
    }),
    order   => '15'
  }
}
