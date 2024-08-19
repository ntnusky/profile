# Installs the generic web-cert for haproxy usage
class profile::services::haproxy::certs {
  include ::profile::services::apache::firewall
  require ::profile::services::haproxy

  # Is this a management or a services loadbalancer?
  $profile = lookup('profile::haproxy::web::profile')

  # Retrieve the certs:
  $certificate = lookup("profile::haproxy::${profile}::webcert", {
    'default_value' => undef,
    'value_type'    => Optional[String],
  })
  $certfile = lookup("profile::haproxy::${profile}::webcert::certfile", {
    'default_value' => '/etc/ssl/private/haproxy.pem',
    'value_type'    => String,
  })

  if ($certificate) {
    file { $certfile:
      ensure    => 'present',
      content   => $certificate,
      mode      => '0600',
      show_diff => false,
    }

    File[$certfile] ~> Service['haproxy']
  }
}
