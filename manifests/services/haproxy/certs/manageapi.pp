# Install the cacertificate for the management-api
class profile::services::haproxy::certs::manageapi {
  $certificate = hiera('profile::haproxy::management::apicert', false)
  $certfile = hiera('profile::haproxy::management::apicert::certfile',
                    '/etc/ssl/private/haproxy.managementapi.pem')

  if ($certificate) {
    file { $certfile:
      ensure  => 'present',
      content => $certificate,
      mode    => '0600',
      notify  => Service['haproxy'],
    }
  }
}
