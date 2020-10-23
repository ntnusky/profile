# Creates a systemd-service running a program/script as a background daemon
define profile::systemd::service (
  Boolean                    $enable,
  Enum['running', 'stopped'] $ensure,
  String                     $command,
  String                     $description,
) {
  include ::profile::systemd::reload

  # Configure systemd service
  file { "/lib/systemd/system/${name}.service":
    ensure  => file,
    mode    => '0644',
    owner   => root,
    group   => root,
    notify  => Exec['systemd-reload'],
    content => epp('profile/systemd.service.epp', {
      'description' => $description,
      'command'     => $command,
    })
  }

  # Make sure the service is running
  service { "${name}":
    ensure   => $ensure,
    enable   => $enable,
    provider => 'systemd',
    require  => [
      File["/lib/systemd/system/${name}.service"],
      Exec['systemd-reload'],
    ],
  }
}
