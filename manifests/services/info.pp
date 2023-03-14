# Define an apache vhost for random static info
class profile::services::info {
  $vhost = lookup('profile::info::maillist::fqdn', Stdlib::Fqdn)
  $management_if = lookup('profile::interfaces::management', String)
  $mip = $facts['networking']['interfaces'][$management_if]['ip']
  $management_ipv4 = lookup("profile::baseconfig::network::interfaces.${management_if}.ipv4.address", {
    'value_type'    => Stdlib::IP::Address::V4,
    'default_value' => $mip,
  })
  $management_ipv6 = $::facts['networking']['interfaces'][$management_if]['ip6']
  $auth_password = lookup('profile::info::auth_password', String)
  $auth_user = lookup('profile::info::auth_user', String, 'first', 'sympa')
  $pw_hash = apache::pw_hash($auth_password)

  require ::profile::services::apache
  contain ::profile::services::info::maillist

  apache::vhost { "${vhost}-http":
    servername        => $vhost,
    port              => 80,
    ip                => concat([], $management_ipv4, $management_ipv6),
    add_listen        => false,
    docroot           => "/var/www/${vhost}",
    access_log_format => 'forwarded',
    directories       => [
      {
        path           => "/var/www/${vhost}/mail",
        options        => '-Indexes',
        auth_type      => 'Basic',
        auth_name      => 'Maillist auth',
        auth_user_file => "/var/www/${vhost}/.htpasswd",
        auth_require   => 'valid-user',
      },
    ],
  }

  file { "/var/www/${vhost}/.htpasswd":
    ensure  => file,
    owner   => 'root',
    group   => 'www-data',
    mode    => '0440',
    content => "${auth_user}:${pw_hash}",
  }

  ensure_packages ( ['ldap-utils'], {
      'ensure' => 'present',
  })
}
