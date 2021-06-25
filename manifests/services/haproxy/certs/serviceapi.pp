# Install the cacertificate for the services-api
class profile::services::haproxy::certs::serviceapi {

  $certificate = lookup('profile::haproxy::services::apicert', {
    'default_value' => false,
    'value_type'    => Variant[Boolean, String],
  })
  $certfile = lookup('profile::haproxy::services::apicert::certfile', {
    'default_value' => '/etc/ssl/private/haproxy.servicesapi.pem'
    'value_type'    => Stdlib::Unixpath,
  })

  if ($certificate) {
    file { $certfile:
      ensure  => 'present',
      content => $certificate,
      mode    => '0600',
      notify  => Service['haproxy'],
    }
  }
}
