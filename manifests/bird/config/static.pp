# Adds static-routes for bird
define profile::bird::config::static (
  String $configfile,
  Hash $prefixes,
) {
  concat::fragment { "Bird Static ${name}":
    target  => $configfile,
    content => epp('profile/bird/static.epp', {
      'prefixes' => $prefixes,
    }),
    order   => '13'
  }
}
