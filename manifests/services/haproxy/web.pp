# Create a loadbalancer for web resources
class profile::services::haproxy::web {
  include ::profile::services::apache::firewall
  require ::profile::services::haproxy

  # Is this a management or a services loadbalancer?
  $profile = lookup('profile::haproxy::web::profile')

  # Collect the addresses to bind to; or get false if the address is not used.
  $anycastv4 = lookup("profile::anycast::${profile}::ipv4", {
    'value_type'    => Variant[Stdlib::IP::Address::V4, Boolean],
    'default_value' => false,
  })
  $anycastv6 = lookup("profile::anycast::${profile}::ipv6", {
    'value_type'    => Variant[Stdlib::IP::Address::V6, Boolean],
    'default_value' => false,
  })
  $keepalivedipv4 = lookup("profile::haproxy::${profile}::ipv4", {
    'value_type'    => Variant[Stdlib::IP::Address::V4, Boolean],
    'default_value' => false,
  })
  $keepalivedipv6 = lookup("profile::haproxy::${profile}::ipv6", {
    'value_type'    => Variant[Stdlib::IP::Address::V6, Boolean],
    'default_value' => false,
  })
  $a = concat([], $anycastv4, $anycastv6, $keepalivedipv4, $keepalivedipv6)
  $addresses = delete($a, false)

  # Collect domains to serve
  $domains = lookup("profile::haproxy::${profile}::domains", {
    'value_type' => Hash,
    'merge'      => 'hash',
  })

  $certificate = lookup("profile::haproxy::${profile}::webcert", {
    'default_value' => false,
  })
  $certfile = lookup("profile::haproxy::${profile}::webcert::certfile", {
    'default_value' => '/etc/ssl/private/haproxy.pem',
    'value_type'    => String,
  })
  $nossl = lookup("profile::haproxy::${profile}::nossl", {
    'value_type'    => Variant[Boolean, String],
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

  if($certificate) {
    if ($nossl) {
      $redirect = { 'redirect' =>
        "scheme https code 301 if !{ ssl_fc } ! { hdr_dom(host) -m beg ${nossl} }"
      }
    } else {
      $redirect = { 'redirect' => 'scheme https code 301 if !{ ssl_fc }' }
    }

    $ssl_bind = $addresses.reduce({}) | $memo, $address | {
      $memo + {"${address}:443" => ['ssl', 'crt', $certfile]}
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

  if ($certificate) {
    file { $certfile:
      ensure  => 'present',
      content => $certificate,
      mode    => '0600',
      notify  => Service['haproxy'],
    }
  }
}
