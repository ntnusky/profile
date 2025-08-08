# Module to install erlang from Erlangs repositories
class profile::services::erlang {
  $version = lookup('profile::services::erlang::version', {
    'default_value' => '1:25.3.2.21-1',
  })

  $distro = $facts['os']['distro']['codename']

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
    version  => $version,
    priority => 1000,
  }
}
