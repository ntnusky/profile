# Define an apache vhost for random static info
class profile::services::info {
  $vhost = lookup('profile::info::maillist::fqdn', {
    'default_value' => undef, 
    'value_type'    => Optional[Stdlib::Fqdn],
  })

  if($vhost) {
    $auth_password = lookup('profile::info::auth_password', String)
    $auth_user = lookup('profile::info::auth_user', String, 'first', 'sympa')
    $pw_hash = apache::pw_hash($auth_password)

    require ::profile::services::apache
    contain ::profile::services::info::maillist

    apache::vhost { "${vhost}-http":
      servername        => $vhost,
      port              => 80,
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
}
