# Configure the dashboard clients for TFTP 
class profile::services::dashboard::clients::tftp {
  require ::profile::services::dashboard::install

  $cert = lookup('profile::haproxy::management::webcert', {
    'default_value' => false,
  })
  $slname = lookup('profile::dashboard::name', String)
  $tftpdir = lookup('profile::tftp::root', String, 'first', '/var/lib/tftpboot/')

  if($cert) {
    $proto = 'https'
  } else {
    $proto = 'http'
  }

  $slurl="${proto}://${slname}"

  cron { 'Dashboard-client tftp':
    command => '/opt/shiftleader/manage.py create_tftp',
    user    => 'root',
    minute  => '*',
  }

  file { '/usr/local/bin/tftpkernels.sh':
    ensure  => file,
    owner   => 'root',
    mode    => '0755',
    content => template('profile/tftpkernels.erb'),
  }

  cron { 'Dashboard-client tftpimages':
    command => '/usr/local/bin/tftpkernels.sh',
    user    => 'root',
    minute  => '*',
  }
}
