# Installs the ssl certificates used by horizon
class profile::openstack::horizon::ssl {
  $ssl_key = hiera('profile::horizon::ssl_key')
  $ssl_cert = hiera('profile::horizon::ssl_cert')
  $ssl_ca = hiera('profile::horizon::ssl_ca')

  file { '/etc/ssl/private/horizon.key':
    ensure  => file,
    content => $ssl_key,
    notify  => Service['httpd'],
  }
  file { '/etc/ssl/certs/horizon.crt':
    ensure  => file,
    content => $ssl_cert,
    notify  => Service['httpd'],
  }
  file { '/etc/ssl/certs/CA.crt':
    ensure  => file,
    content => $ssl_ca,
    notify  => Service['httpd'],
  }
}
