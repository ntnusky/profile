# HTTPS certificate checks
# And web availability checks
class profile::sensu::checks::web {

  $domains = lookup('profile::sensu::checks::web', Hash[Stdlib::Fqdn, String])

  $domains.each | $domain, $displayname | {
    sensu::check { "web-${displayname}":
      command     => "check-http.rb -r -u https://${domain}",
      interval    => 300,
      standalone  => false,
      subscribers => [ 'web' ],
    }
  }
}
