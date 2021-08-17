# Install the cacertificate for the management-api
class profile::services::haproxy::certs::manageapi {
  $certificate = lookup('profile::haproxy::management::apicert', {
    'default_value' => false,
    'value_type'    => Variant[Boolean, String],
  })
  $certfile = lookup('profile::haproxy::management::apicert::certfile', {
    'default_value' => '/etc/ssl/private/haproxy.managementapi.pem',
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
