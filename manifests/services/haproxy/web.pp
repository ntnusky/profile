# Create a loadbalancer for web resources
class profile::services::haproxy::web {
  include ::profile::services::apache::firewall
  require ::profile::services::haproxy

  $profile = hiera('profile::haproxy::web::profile')
  $domains = hiera_hash("profile::haproxy::${profile}::domains")
  $ipv4 = hiera("profile::haproxy::${profile}::ipv4")
  $ipv6 = hiera("profile::haproxy::${profile}::ipv6", false)

  $acl = $domains.map |String $domain, String $name| {
    "host_${name} hdr_dom(host) -m dom ${domain}"
  }
  $backend = $domains.map |String $domain, String $name| {
    "bk_${name} if host_${name}"
  }

  if($ipv6) {
    $bind = {
      "${ipv4}:80"  => [],
      "${ipv4}:443" => [],
      "${ipv6}:80"  => [],
      "${ipv6}:443" => [],
    }
  } else {
    $bind = {
      "${ipv4}:80"  => [],
      "${ipv4}:443" => [],
    }
  }

  ::haproxy::frontend { 'ft_web':
    bind    => $bind,
    mode    => 'http',
    options => {
      'acl'         => $acl,
      'use_backend' => $backend,
      'option'      => [
        'forwardfor',
        'http-server-close',
      ],
    },
  }

}
