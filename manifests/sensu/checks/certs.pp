# HTTPS certificate checks
# And web availability checks
class profile::sensu::checks::certs {

  $domains = lookup('profile::sensu::checks::tlsexpiry', Hash[Stdlib::Fqdn, String])

  $domains.each | $domain, $displayname | {
    sensu::check { "tls-expiry-${displayname}":
      command     => "check-https-cert.rb -u https://${domain} -w 30 -c 7",
      interval    => 300,
      standalone  => false,
      subscribers => [ 'tls-expiry' ],
    }
  }
}
