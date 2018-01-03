# Configure the haproxy frontend for shiftleader.
class profile::services::dashboard::haproxy::frontend {
  include ::profile::services::apache::firewall
  require ::profile::services::haproxy

  $domain = hiera('profile::dashboard::name')
  $ipv4 = hiera('profile::haproxy::management::ipv4')
  $ipv6 = hiera('profile::haproxy::management::ipv6', false)
  $ft_options = {
    'acl'         => "host_shiftleader hdr_dom(host) -m dom ${domain}",
    'use_backend' => 'bk_shiftleader if host_shiftleader',
    'option'      => [
      'forwardfor',
      'http-server-close',
    ],
  }

  if($ipv6) {
    haproxy::frontend { 'ft_shiftleader':
      bind    => {
        "${ipv4}:80"  => [],
        "${ipv4}:443" => [],
        "${ipv6}:80"  => [],
        "${ipv6}:443" => [],
      },
      mode    => 'http',
      options => $ft_options,
    }
  } else {
    haproxy::frontend { 'ft_shiftleader':
      ipaddress => $ipv4,
      ports     => '80,443',
      mode      => 'http',
      options   => $ft_options,
    }
  }
}
