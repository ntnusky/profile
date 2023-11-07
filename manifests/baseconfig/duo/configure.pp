# Configures duo 
class profile::baseconfig::duo::configure {
  include profile::baseconfig::duo::install

  $duo_host = lookup('profile::duo::api::hostname')
  $duo_integration = lookup('profile::duo::api::integration')
  $duo_secret = lookup('profile::duo::api::secret')

  $common = {
    ensure  => present,
    path    => '/etc/duo/pam_duo.conf',
    section => 'duo',
    require => Package['duo-unix'],
  }

  ini_setting { 'DUO-API':
    setting => 'host',
    value   => $duo_host,
    *       => $common,
  }
  ini_setting { 'DUO-Integration':
    setting => 'ikey',
    value   => $duo_integration,
    *       => $common,
  }
  ini_setting { 'DUO-Secret':
    setting   => 'skey',
    value     => $duo_secret,
    show_diff => false,
    *         => $common,
  }

  ini_setting { 'DUO-Groups':
    setting => 'groups',
    value   => '*,!root',
    *       => $common,
  }
  ini_setting { 'DUO-Pushinfo':
    setting => 'pushinfo',
    value   => 'yes',
    *       => $common,
  }
  ini_setting { 'DUO-Autopush':
    setting => 'autopush',
    value   => 'yes',
    *       => $common,
  }
  ini_setting { 'DUO-failmode':
    setting => 'failmode',
    value   => 'secure',
    *       => $common,
  }

  # Add a PAM-file for unix-passwod + DUO
  file { '/etc/pam.d/common-auth-duo':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/profile/pam/duo-common-auth',
  }
  
  # Make SSH use the unix+DUO PAM config
  file_line { 
    ensure             => present,
    path               => '/etc/pam.d/sshd',
    line               => '@include common-auth-duo',
    match              => '@include common-auth',
    append_on_no_match => false,
  }
}
