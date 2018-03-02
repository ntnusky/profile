# HTTPS certificate checks
# And web availability checks
class profile::sensu::checks::web {

  $domains = hiera_hash('profile::sensu::checks::tlsexpiry')

  $domains.each | $domain, $displayname | {
    sensu::check { "tls-expiry-${displayname}":
      command     => "check-https-cert.rb -u https://${domain} -w 30 -c 7",
      interval    => 300,
      standalone  => false,
      subscribers => [ 'tls-expiry' ],
    }
    sensu::check { "web-${displayname}":
      command     => "check-http.rb -r -u https://${domain}"
      interval    => 300,
      standalone  => false,
      subscribers => [ 'web' ],
    }
  }
}
