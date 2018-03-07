# HTTPS certificate checks
# And web availability checks
class profile::sensu::checks::web {

  $domains = hiera_hash('profile::sensu::checks::web')

  $domains.each | $domain, $displayname | {
    sensu::check { "web-${displayname}":
      command     => "check-http.rb -r -u https://${domain}",
      interval    => 300,
      standalone  => false,
      subscribers => [ 'web' ],
    }
  }
}
