# Installs the generic web-cert for haproxy usage
class profile::services::haproxy::certs {
  require ::profile::services::haproxy

  # Retrieve the certs:
  $certificate = lookup("profile::haproxy::web::cert", {
    'default_value' => undef,
    'value_type'    => Optional[String],
  })
  $certfile = lookup("profile::haproxy::web::cert::filename", {
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
