# Module to install erlang from Erlangs repositories
class profile::services::erlang {
  $erlang_version = lookup('profile::services::erlang::version', {
    'default_value' => 'auto',
  })

  $rabbit_version = lookup('rabbitmq::package_ensure')
  $distro = $facts['os']['distro']['codename']

  if ( versioncmp($rabbit_version, '3.10.13-1') == 1 ) {

    if ( $erlang_version == 'auto' ) {
      $erlang_version_real = $rabbit_version ? {
        /^(3.10.2?|3.11)/ => '1:25.3.2.21-1',
        /^(3.12|3.13)/    => '1:26.2.5.13-1',
        /^(4.0|4.1)/      => '1:27.3.4.2-1',
        default           => undef,
      }
    } else {
      $erlang_version_real = $erlang_version
    }

    if (!$erlang_version_real) {
      fail("Rabbit version ${rabbit_version} is not supported")
    }

    apt::source { 'erlang':
      comment  => '',
      location => "https://deb1.rabbitmq.com/rabbitmq-erlang/ubuntu/${distro}",
      release  => $distro,
      repos    => 'main',
      key      => {
        id     => '0A9AF2115F4687BD29803A206B73A36E6026DFCA',
        source => 'https://keys.openpgp.org/vks/v1/by-fingerprint/0A9AF2115F4687BD29803A206B73A36E6026DFCA',
      },
      notify   => Exec['apt_update'],
      before   => Apt::Pin['erlang'],
    }

    apt::pin { 'erlang':
      packages => 'erlang*',
      version  => $erlang_version_real,
      priority => 1000,
    }

    package { 'erlang':
      ensure        => $erlang_version_real,
      allow_virtual => true,
      require       => [ Apt::Source['erlang'], Exec['apt_update'] ],
    }
  }
}
