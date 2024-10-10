# Create a loadbalancer for web resources
class profile::services::haproxy::web {
  include ::profile::services::apache::firewall
  include ::profile::services::haproxy::certs
  require ::profile::services::haproxy

  # Collect the addresses to bind to; or get false if the address is not used.
  $anycastv4 = lookup("profile::anycast::ipv4", {
    'value_type'    => Variant[Stdlib::IP::Address::V4, Boolean],
    'default_value' => false,
  })
  $anycastv6 = lookup("profile::anycast::ipv6", {
    'value_type'    => Variant[Stdlib::IP::Address::V6, Boolean],
    'default_value' => false,
  })
  $a = concat([], $anycastv4, $anycastv6)
  $addresses = delete($a, false)

  # Collect domains to serve
  $domains = lookup("profile::haproxy::domains", {
    'default_value' => {},
    'merge'         => 'hash',
    'value_type'    => Hash,
  })

  $certificate = lookup("profile::haproxy::web::cert", {
    'default_value' => false,
  })
  $certfile = lookup("profile::haproxy::web::cert::filename", {
    'default_value' => '/etc/ssl/private/haproxy.pem',
    'value_type'    => String,
  })

  $addpuppetcert = lookup('profile::haproxy::tls::puppetcert', {
    'value_type'    => Boolean,
    'default_value' => false,
  })

  $acl = $domains.map |String $domain, String $name| {
    "host_${name} hdr_dom(host) -m beg ${domain}"
  }
  $backend = $domains.map |String $domain, String $name| {
    "bk_${name} if host_${name}"
  }

  $baseoptions = {
    'acl'                     => $acl,
    'use_backend'             => $backend,
    'option'                  => [
      'forwardfor',
      'http-server-close',
    ],
    'http-request add-header' => 'X-Forwarded-Proto https if { ssl_fc }',
  }

  $base_bind = $addresses.reduce({}) | $memo, $address | {
    $memo + {"${address}:80" => []}
  }

  if($addpuppetcert) {
    $cmdparts = [
      "/usr/bin/cat /etc/puppetlabs/puppet/ssl/private_keys/${::fqdn}.pem",
      "/etc/puppetlabs/puppet/ssl/certs/${::fqdn}.pem",
      '/etc/puppetlabs/puppet/ssl/certs/ca.pem'
    ]
    $joincmd = join($cmdparts, ' ')
    $altcert = '/etc/ssl/private/puppetbundle.pem'

    exec { 'create puppet certbundle':
      command => "${joincmd} > ${altcert}",
      unless  => "/bin/bash -c '/usr/bin/diff <(${joincmd}) ${altcert}'",
    }
    $puppet_bind = ['crt', $altcert]
  } else {
    $puppet_bind = []
  }

  if($certificate) {
    $redirect = { 'redirect' => 'scheme https code 301 if !{ ssl_fc }' }
    $ssl_bind = $addresses.reduce({}) | $memo, $address | {
      $memo + {"${address}:443" => ['ssl', 'crt', $certfile] + $puppet_bind}
    }
  } else {
    $redirect = {}
    $ssl_bind = {}
  }

  $options = deep_merge($baseoptions, $redirect)
  $bind = deep_merge($base_bind, $ssl_bind)

  ::haproxy::frontend { 'ft_web':
    bind    => $bind,
    mode    => 'http',
    options => $options,
  }
}
