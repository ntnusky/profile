# Create a loadbalancer for web resources
class profile::services::haproxy::web {
  include ::profile::services::apache::firewall
  require ::profile::services::haproxy

  $profile = hiera('profile::haproxy::web::profile')
  $domains = hiera_hash("profile::haproxy::${profile}::domains")
  $ipv4 = hiera("profile::haproxy::${profile}::ipv4")
  $ipv6 = hiera("profile::haproxy::${profile}::ipv6", false)
  $certificate = hiera("profile::haproxy::${profile}::webcert", false)
  $certfile = hiera("profile::haproxy::${profile}::webcert::certfile",
                    '/etc/ssl/private/haproxy.pem')
  $nossl = hiera("profile::haproxy::${profile}::nossl", false)

  $acl = $domains.map |String $domain, String $name| {
    "host_${name} hdr_dom(host) -m str ${domain}"
  }
  $backend = $domains.map |String $domain, String $name| {
    "bk_${name} if host_${name}"
  }

  $baseoptions = {
    'acl'         => $acl,
    'use_backend' => $backend,
    'option'      => [
      'forwardfor',
      'http-server-close',
    ],
  }

  $bindv4 = {
    "${ipv4}:80" => [],
  }

  if($ipv6) {
    $bindv6 = {
      "${ipv6}:80" => [],
    }
  } else {
    $bindv6 = {}
  }

  if($certificate) {
    if ($nossl) {
      $redirect = { 'redirect' =>
        "scheme https code 301 if !{ ssl_fc } ! { hdr_dom(host) -m str ${nossl} }"
      }
    } else {
      $redirect = { 'redirect' => 'scheme https code 301 if !{ ssl_fc }' }
    }

    if($ipv6) {
      $bindssl = {
        "${ipv4}:443" => ['ssl', 'crt', $certfile],
        "${ipv6}:443" => ['ssl', 'crt', $certfile],
      }
    } else {
      $bindssl = { "${ipv4}:443" => ['ssl', 'crt', $certfile]  }
    }

  } else {
    $redirect = {}
    $bindssl = {}
  }
  $options = deep_merge($baseoptions, $redirect)
  $bind = deep_merge($bindv4, $bindv6, $bindssl)

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
